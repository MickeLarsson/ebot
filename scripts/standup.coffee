'use strict'

cron = require 'cron'
participants = ['Ridder', 'William', 'Johan', 'Larsson', 'Jeremi', 'Storm', 'Alex', 'Emil', 'Jimbo']

module.exports = (robot) ->
	# timer = '* * * * * *'
	timer = '00 58 09 * * 1-5'

	robot.random = (items) ->
		items[ Math.floor(Math.random() * items.length) ]

	cronJob = cron.CronJob
	standupNotifier = new cronJob(timer, () -> 
			robot.messageRoom '#dev', '@channel: Standup om 2min, idag ska ' + robot.random(participants) + ' börja tala'
		, true, 'Europe/Stockholm')

