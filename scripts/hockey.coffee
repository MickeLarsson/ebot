
request = require 'request'
cheerio = require 'cheerio'
path = require 'path'
crawlUrl = ''
list = []
util = require 'util'
fs = require 'fs'
genSql = ''
baseUrl = 'http://stats.swehockey.se/ScheduleAndResults/Schedule/'


module.exports = (robot) ->
	ebot =
		getDivision: (msg) ->
			crawlUrl = list.pop()

			request uri: crawlUrl, (err, response, body) ->
				$ = cheerio.load body
				headLine = $('.primary > h1').text()
				id = crawlUrl.substring crawlUrl.lastIndexOf('/')+1, crawlUrl.length
				url = crawlUrl.replace id, '{0}'

				ifSql = util.format('IF (SELECT COUNT(*) FROM tCompetition WHERE intSportId = 3 AND intCrawlParam0 = \'%s\') = 0\r\n', id);
				ifSql += 'BEGIN\r\n';
				insertSql = util.format('\tINSERT INTO tCompetition(intSportId, intSfId, intSeasonId, strCompetitionName, strCrawlUrl, intCrawlParam0, intDelete) VALUES(3, NULL, 11, \'%s\', \'%s\', \'%s\', 0)\r\n', headLine, url, id);
				insertSql += '\tINSERT INTO tCompetitionSf(intCompetitionId, intSfId) VALUES(SCOPE_IDENTITY(), 156175)\r\n';
				insertSql += 'END\r\n';
				genSql += ifSql + insertSql;

				if list.length > 0
					ebot.getDivision msg
				else
					ebot.writeFile msg, genSql


		writeFile: (msg, genSql) -> 
			beginTrans = 'BEGIN TRANSACTION\r\n\r\nUSE [dbOrg]\r\n';
			rollbackTrans = '\r\n\r\nROLLBACK TRANSACTION';
			msg.reply beginTrans + genSql + rollbackTrans

	robot.hear /bark/i, (msg) ->
		msg.send 'Voff voff'

	robot.respond /import (.*)/i, (msg) ->
		urls = msg.match[1]
		list = urls.split ' '
		if list.length > 0
			genSql = ''
			ebot.getDivision msg
		else
			msg.reply 'sorry I could not parse that'

	robot.respond /fetch (.*)/i, (msg) ->
		ids = msg.match[1]
		list = ids.split(' ').map (n) -> baseUrl + n
		if list.length > 0
			genSql = ''
			ebot.getDivision msg
		else
			msg.reply 'sorry I could not parse that'

