var http = require('http')
var afs = require('fs')

var server = http.createServer(function(req, res) {
  if (req.method == 'POST') {
      console.log("POST")
      var postData = ''
      req.on('data', function (data) {
          postData += data
      });
      req.on('end', function () {
          var location = JSON.parse(postData)
          var locationTime = location.time
          if (locationTime) {
            let locationDate =  new Date(locationTime)
            console.log('Location received at: ' + locationDate.toTimeString())

          }
          if (location.lat && location.long) {
            console.log('Lat: ' +  location.lat)
            console.log('Lat: ' + location.long)
          }
      })
      res.writeHead(200, {'Content-Type': 'text/html'})
      res.end('post received')
  }
  res.writeHead(200, {'Content-Type': 'text/html'})
  res.end('post received')
})

server.listen(8080)
