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
latestReviewNo = 1010864779
roomName = "#room1"

module.exports = (robot) ->

  # itunes store のレビュー
  new CronJob(
    cronTime: "0 */5 * * * 1-5"
    onTick: () ->  
  #robot.hear /^レビュー/g, (msg) ->
      url = "https://itunes.apple.com/jp/rss/customerreviews/id=307764057/sortBy=mostRecent/json"
      exec = require('child_process').exec 
      exec "curl " + url, (error, stdout, stderr) ->
        json = JSON.parse(stdout)
        entry = json.feed.entry
        entry.shift()
        messageQueue = []
        queueLength = 0
        for i,value of entry
          if latestReviewNo >= +value['id']['label'] then continue
          latestReviewNo = +value['id']['label']

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
          message.star = "#{stars} #{value.author.name.label}　(ver.#{value['im:version']['label']})"
          message.comment = "#{value['title']['label']}：#{content}"
          message.bar = "------------------------------------"
          messageQueue.push message
          queueLength = messageQueue.length

        for num in [0..messageQueue.length-1]
          message = messageQueue.shift()
          for key, value of message
            console.log(value)
            robot.send {room: roomName}, value

            # wait 6秒
            date = new Date()
            curDate = new Date()
            while curDate-date < 600
              curDate = new Date()

        if +queueLength != 0 then robot.send {room: roomName}, "以上、ありがたいお言葉でした"
    start: true
    timeZone: "Japan"
  )
