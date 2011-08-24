#!/usr/bin/env ruby

require 'net/http'

raise "Need to supply a host to connect to" if ARGV.empty?
HOST = ARGV.first  
PORT = ARGV[1] || '80'
 
$payload = <<'GITHUB'
{
  "after": "d0e9ff6d9c1f8bc374856ca2a84ad52d6013b5bf", 
  "base_ref": null, 
  "before": "9759091947134289a10a85ea11bb47efb56c991a", 
  "commits": [
    {
      "added": [
        "app\/controllers\/admin1_codes_controller.rb", 
        "app\/views\/cities\/edit.html.erb", 
        "app\/views\/geo_hierarchies\/index.html.erb", 
        "test\/fixtures\/postal_codes.yml", 
        "test\/functional\/postal_codes_controller_test.rb", 
      ], 
      "author": {
        "email": "ryan@rtlong.com", 
        "name": "Ryan Taylor Long", 
        "username": "rtlong"
      }, 
      "distinct": true, 
      "id": "dbd2b8bebdd0612c46937397a0ddef6536c3a8e1", 
      "message": "Add several models\/scaffolds that go along with the Geonames tables\n\nNote the use of the City model for the 'geonames' table. All the geonames\ntables use 'geoname_id' as a foreign key, so to keep those happy, lets just\nuse 'geonames' instead  of 'cities' even though it's only going to be cities\nin that table.", 
      "modified": [
        "app\/controllers\/cities_controller.rb", 
        "app\/models\/resume.rb", 
        "app\/views\/cities\/index.html.erb", 
        "test\/unit\/city_test.rb"
      ], 
      "removed": [], 
      "timestamp": "2011-08-21T02:30:18-07:00", 
      "url": "https:\/\/github.com\/rtlong\/referral-bonus\/commit\/dbd2b8bebdd0612c46937397a0ddef6536c3a8e1"
    }, 
    {
      "added": [], 
      "author": {
        "email": "ryan@rtlong.com", 
        "name": "Ryan Taylor Long", 
        "username": "rtlong"
      }, 
      "distinct": true, 
      "id": "ea2ffdfd8d507d3fb3038a6444512d5a5b637c93", 
      "message": "Fix db\/seeds.rb to reflect recent database structure modifications", 
      "modified": [
        "db\/seeds.rb", 
        "db\/seeds.yml", 
        "lib\/tasks\/geonames.rake"
      ], 
      "removed": [], 
      "timestamp": "2011-08-21T02:42:22-07:00", 
      "url": "https:\/\/github.com\/rtlong\/referral-bonus\/commit\/ea2ffdfd8d507d3fb3038a6444512d5a5b637c93"
    }, 
    {
      "added": [], 
      "author": {
        "email": "ryan@rtlong.com", 
        "name": "Ryan Taylor Long", 
        "username": "rtlong"
      }, 
      "distinct": true, 
      "id": "d0e9ff6d9c1f8bc374856ca2a84ad52d6013b5bf", 
      "message": "!temp Fix resume_cities table !temp\n\nThis is meant to be on the @bacbeb2e36c50400966e commit with the rest of the\nmigration. I am waiting to hear back from the community on a problem I am\nhaving with git regarding that...", 
      "modified": [
        "db\/migrate\/20110816214834_create_all_tables.rb", 
        "db\/schema.rb"
      ], 
      "removed": [], 
      "timestamp": "2011-08-21T16:17:56-07:00", 
      "url": "https:\/\/github.com\/rtlong\/referral-bonus\/commit\/d0e9ff6d9c1f8bc374856ca2a84ad52d6013b5bf"
    }
  ], 
  "compare": "https:\/\/github.com\/rtlong\/referral-bonus\/compare\/9759091...d0e9ff6", 
  "created": false, 
  "deleted": false, 
  "forced": false, 
  "pusher": {
    "name": "none"
  }, 
  "ref": "refs\/heads\/master", 
  "repository": {
    "created_at": "2011\/04\/17 22:52:01 -0700", 
    "description": "", 
    "fork": true, 
    "forks": 0, 
    "has_downloads": true, 
    "has_issues": false, 
    "has_wiki": false, 
    "homepage": "referral-bonus.com", 
    "language": "Ruby", 
    "master_branch": "master", 
    "name": "referral-bonus", 
    "open_issues": 0, 
    "owner": {
      "email": "ryan@rtlong.com", 
      "name": "rtlong"
    }, 
    "private": true, 
    "pushed_at": "2011\/08\/21 16:19:51 -0700", 
    "size": 120, 
    "url": "https:\/\/github.com\/rtlong\/referral-bonus", 
    "watchers": 1
  }
}
GITHUB

# define them as methods so they can be called in irb
def github_post
  Net::HTTP.post_form URI.parse("http://#{HOST}:#{PORT}/"), { 'payload' => $payload }
end

def heroku_post
  git_log = <<-LOG
  * Ryan Taylor Long: Moved back to gem versions of linkedin, omniauth, and twitter
  * Ryan Taylor Long: Added the active_reload gem
  * Ryan Taylor Long: Updated gems
  * Ryan Taylor Long: Ignore the node-specific foreman config file
  * Ryan Taylor Long: Added a config file for the god gem which will help to run deployed workers.
  * Ryan Taylor Long: Updated gems again
  * Ryan Taylor Long: Show ENV on the /admin/info page for debugging
LOG
  params = { 'app' => 'social-jobs', 
             'git_log' => git_log, 
             'head' => '0c49a57', 
             'head_long' => '0c49a579c3d1d5b084f8561d93b9111edbaf858a',
             'prev_head' => '4ff82fa', 
             'url' => 'social-jobs.herokuapp.com', 
             'user' => 'ryan@rtlong.com' }
  
  Net::HTTP.post_form URI.parse("http://#{HOST}:#{PORT}/heroku"), params
end

# call them now in case it's being called on the command line
heroku_post
github_post
