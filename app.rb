require 'sinatra'
require 'json'
require 'fileutils'

before do
  content_type :json
end

post '/payload/:repo' do
  repo = params['repo']
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body, repo)
  # push = JSON.parse(payload_body)
  update_repo(repo)

  { status: 'ok'}.to_json
end

def verify_signature(payload_body, repo)
  token = ENV["HOOK_TOKEN_#{repo.upcase}"]

  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), token, payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end

def update_repo(repo)
  FileUtils.touch(File.join(ENV['APP_DIR'], "#{repo}.txt"))
end
