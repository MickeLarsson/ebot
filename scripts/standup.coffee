'use strict'

cron = require 'cron'

module.exports = (robot) ->
	timer = '00 58 09 * * 1-5'

	cronJob = cron.CronJob
	standupNotifier = new cronJob(timer, () -> 
			robot.messageRoom '#dev', 'Standup om 2min!'
		, true, 'Europe/Stockholm')

