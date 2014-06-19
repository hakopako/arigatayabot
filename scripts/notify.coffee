# Description:
#   app store のありがたいレビューを流してくれるbot   
#   https://itunes.apple.com/jp/rss/customerreviews/id=307764057/sortBy=mostRecent/xml
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   shi-man

CronJob = require('cron').CronJob
request = require('request')
lastReviewNo = 1012540839
roomName = "#room1"

module.exports = (robot) ->

  # itunes store のレビュー
  new CronJob(
    cronTime: "0 * * * * 1-5"
    onTick: () ->  
  #robot.hear /^レビュー/g, (msg) ->
      url = "https://itunes.apple.com/jp/rss/customerreviews/id=307764057/sortBy=mostRecent/json"
      request url, (error, response, body) ->
        json = JSON.parse(body)
        entry = json.feed.entry
        entry.shift()
        messageQueue = []
        queueLength = 0
        newestReviewNo = -1
        for i,value of entry
          if +i is 0 then newestReviewNo = +value['id']['label']
          if lastReviewNo >= +value['id']['label'] then continue
          
          starnum = +value['im:rating']['label']
          if starnum is 0 then stars = "☆☆☆☆☆"
          else if starnum is 1 then stars = "★☆☆☆☆"
          else if starnum is 2 then stars = "★★☆☆☆"
          else if starnum is 3 then stars = "★★★☆☆"
          else if starnum is 4 then stars = "★★★★☆"
          else if starnum is 5 then stars = "★★★★★"
          else stars = "★☆☆☆☆"

          content = value['content']['label'].replace(/\n/g, "")

          message = {}
          message.star = "#{stars} #{value.author.name.label}　(ver.#{value['im:version']['label']} / No.#{value.id.label})"
          message.comment = "#{value['title']['label']}：#{content}"
          message.bar = "------------------------------------"
          messageQueue.push message
          queueLength = messageQueue.length

        if +queueLength isnt 0 then lastReviewNo = newestReviewNo 

        for num in [0..messageQueue.length-1]
          message = messageQueue.pop()
          for key, value of message
            robot.send {room: roomName}, value

            # wait 6秒
            date = new Date()
            curDate = new Date()
            while curDate-date < 600
              curDate = new Date()

        if +queueLength isnt 0 then robot.send {room: roomName}, "以上、ありがたいお言葉でした"
    start: true
    timeZone: "Japan"
  )
