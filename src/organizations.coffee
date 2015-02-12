# Description:
#   Allow Hubot to manage your github organization members and teams
#
# Dependencies:
#   "github": "latest"
#
# Configuration:
#   HUBOT_GITHUB_KEY - Github Application Key
#   HUBOT_GITHUB_ORG - Github Organization Name
#   HUBOT_SLACK_ADMIN - Userid of slack admins who can use these commands
#
# Commands:
#   hubot gho list members|users - returns a list of all of the users and members of your org
#
# Author:
#   Ollie Jennings <ollie@olliejennings.co.uk>

org = require './libs/org'
admins = []


# TODO - ideal commands
# - createThin layer for parsing commands
# - create (team|repo) with (extras)
# - add (members|repos) to (team|organization)
# - list (teams|members|repos) of (extra)
# - move (member|members|repos|repo) (to|from) (team) to (team)
# - remove (member|team) from (team|organization)



##############################
# API Methods
##############################

isAdmin = (user) ->
  user.id.toString() in admins

ensureConfig = (out) ->
  out "Error: Github App Key is not specified" if not process.env.HUBOT_GITHUB_KEY
  out "Error: Github organization name is not specified" if not process.env.HUBOT_GITHUB_ORG
  out "Error: Slack Admin userid is not specified" if not process.env.HUBOT_SLACK_ADMIN
  return false unless (process.env.HUBOT_GITHUB_KEY and process.env.HUBOT_GITHUB_ORG and process.env.HUBOT_SLACK_ADMIN)
  true

getOrgMembers = (msg, orgName) ->
  ensureConfig msg.send
  github.orgs.getMembers org: orgName, per_page: 100, (err, res) ->
    msg.reply "There was an error getting the members for organization: #{orgName}" if err
    msg.send "* <#{user.url}|#{user.login}>" for user in res unless err and res.length == 0


getOrgMember = (msg, username, orgName) ->
  ensureConfig msg.send
  github.orgs.getMember org: orgName, user: username, (err, res) ->
    msg.reply "There was an error getting the details of org member: #{username}" if err
    msg.send "#{username} is part of the organization: #{orgName}" unless err


getOrgTeams = (msg, orgName) ->
  ensureConfig msg.send
  github.orgs.getTeams org: orgName, per_page: 100, (err, res) ->
    msg.reply "There was an error getting the teams for organization: #{orgName}" if err
    msg.send "* <https://github.com/org/#{orgName}/teams/#{team.name}|#{team.name}> - #{team.description}" for team in res unless err and res.length == 0


createOrgTeam = (msg, orgName, teamName, permis="push") ->
  ensureConfig msg.send
  github.orgs.createTeam org: orgName, name: teamName, permission: permis, (err, res) ->
    msg.reply "There was an error creating the team #{teamName} for the organization: #{orgName}" if err
    msg.send "Successfully created the team: '#{res.name}' with '#{res.permission}' permissions" unless err


createOrgTeamWithRepos = (msg, orgName, teamName, repos, permis="push") ->
  ensureConfig msg.send
  console.log repos


getOrgRepos = (msg, orgName, repoType) ->
  ensureConfig msg.send
  github.repos.getFromOrg org: orgName, type: repoType, per_page: 100, (err, res) ->
    msg.reply "There was an error getting all repos for organization: #{orgName}" if err
    msg.send "*<#{repo.html_url}|#{repo.name}> - #{repo.description}" for repo in res unless err and res.length == 0


# org = {
#   isAdmin: (user) ->
#     user.id.toString() in admins

#   summary: (msg) ->
#     # get org summary

#   list: {
#     teams: (msg) ->
#     members: (msg) ->
#     repos: (msg) ->
#   }

#   # create: {
#   #   team: (msg, name) ->
#   #   teams: (msg, names) ->
#   #   repo: (msg, name) ->
#   #   repo: (msg, names) ->
#   # }

#   # remove: {
#   #   member: (msg, name, from) ->
#   #   members: (msg, names, from) ->
#   #   team: (msg, name) ->
#   #   teams: (msg, name) ->
#   #   repo: (msg, name, from) ->
#   #   repos: (msg, names, from) ->
#   # }
# }


module.exports = (robot) ->

  ensureConfig console.log
  admins = process.env.HUBOT_SLACK_ADMIN.split ','
  org.init()


  robot.respond /gho$/i, (msg) ->
    org.summary msg


  robot.respond /gho create (team|repo) ["'](.*?)['"](?:[:])?(?:["'](.*?)['"])?/i, (msg) ->
    console.log msg.match
    org.create[msg.match[1]] msg, msg.match[2], msg.match[3]



  # robot.respond /gho list (teams|members|repos)/i, (msg) ->
  #   console.log msg.match
  #   # org.list[msg.match[1]] msg

  # robot.respond /gho create (team|repo) ["'](.+)["']/i, (msg) ->
  #   unless org.isAdmin msg.message.user
  #     msg.reply "Sorry, only admins can use the github organization create commands"
  #   else
  #     console.log msg.match
      # org.create[msg.match[1]] msg msg.match[2]
