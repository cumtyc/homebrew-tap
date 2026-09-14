# frozen_string_literal: true

require "digest"
require "net/http"
require "rubygems"
require "uri"

VERSION_URI = URI("https://dl.docdot.ai/releases/docdot/latest/version.txt")
ARTIFACT_BASE_URL = "https://dl.docdot.ai/releases/docdot"
ARTIFACT_NAME = "docdot-darwin-arm64"
USER_AGENT = "docdot-homebrew-tap-updater"

def fetch(uri, redirects_remaining: 5)
  raise "too many redirects while fetching #{uri}" if redirects_remaining.negative?
  raise "refusing to fetch non-HTTPS URL: #{uri}" unless uri.is_a?(URI::HTTPS)

  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = USER_AGENT

  response = Net::HTTP.start(
    uri.host,
    uri.port,
    use_ssl: true,
    open_timeout: 15,
    read_timeout: 300,
  ) do |http|
    http.request(request)
  end

  case response
  when Net::HTTPSuccess
    response.body
  when Net::HTTPRedirection
    location = response["location"] or raise "redirect from #{uri} has no location"
    fetch(URI.join(uri.to_s, location), redirects_remaining: redirects_remaining - 1)
  else
    raise "failed to fetch #{uri}: HTTP #{response.code} #{response.message}"
  end
end

def replace_once(contents, pattern, replacement, field)
  matches = contents.scan(pattern)
  raise "expected exactly one #{field} in the formula, found #{matches.length}" unless matches.one?

  contents.sub(pattern, replacement)
end

def write_outputs(updated:, version:)
  output_path = ENV["GITHUB_OUTPUT"]
  return unless output_path

  File.open(output_path, "a") do |output|
    output.puts "updated=#{updated}"
    output.puts "version=#{version}"
  end
end

default_formula_path = File.expand_path("../../Formula/docdot.rb", __dir__)
formula_path = File.expand_path(ARGV.fetch(0, default_formula_path))
formula = File.read(formula_path)

upstream_version = fetch(VERSION_URI).strip.delete_prefix("v")
unless upstream_version.match?(/\A\d+(?:\.\d+)+\z/)
  raise "invalid upstream version: #{upstream_version.inspect}"
end

current_versions = formula.scan(/^  version "([^"]+)"$/).flatten
unless current_versions.one?
  raise "expected exactly one version in the formula, found #{current_versions.length}"
end

current_version = current_versions.first
if Gem::Version.new(upstream_version) <= Gem::Version.new(current_version)
  puts "DocDot formula is current at #{current_version}; upstream is #{upstream_version}."
  write_outputs(updated: false, version: upstream_version)
  exit
end

artifact_url = "#{ARTIFACT_BASE_URL}/#{upstream_version}/#{ARTIFACT_NAME}"
sha256 = Digest::SHA256.hexdigest(fetch(URI(artifact_url)))

formula = replace_once(
  formula,
  %r{^  url "https://dl\.docdot\.ai/releases/docdot/[^"]+/docdot-darwin-arm64", using: :nounzip$},
  %(  url "#{artifact_url}", using: :nounzip),
  "URL",
)
formula = replace_once(
  formula,
  /^  version "[^"]+"$/,
  %(  version "#{upstream_version}"),
  "version",
)
formula = replace_once(
  formula,
  /^  sha256 "[0-9a-f]{64}"$/,
  %(  sha256 "#{sha256}"),
  "SHA-256 checksum",
)

File.write(formula_path, formula)
write_outputs(updated: true, version: upstream_version)
puts "Updated DocDot formula from #{current_version} to #{upstream_version}."
