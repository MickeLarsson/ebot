'use strict'

cron = require 'cron'

module.exports = (robot) ->
	# timer = '00 58 09 * * 1-5'
	timer = '* * * * * *'

	cronJob = cron.CronJob
	standupNotifier = new cronJob(timer, () -> 
			# robot.adapter.send { room: 'dev' }, 'Standup om 2min!'
			robot.messageRoom '#dev', 'Stanup om 2min!'
		, true, 'Europe/Stockholm')

