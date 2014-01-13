
module.exports = (req, target, protocol='http') ->
  dd = (str) ->
    str = String str
    switch str.length
      when 0 then '00'
      when 1 then '0' + str
      when 2 then str
      else
        str.substr str.lenth - 2

  date  = new Date

  year  = date.getFullYear()
  month = dd date.getMonth() + 1
  day   = dd date.getDate()
  hour  = dd date.getHours()
  min   = dd date.getMinutes()
  sec   = dd date.getSeconds()
  ms    = (date.getMilliseconds() + '00').substr 0, 3

  '[' + year + '-' + month + '-' + day + ' ' +
  hour + ':' + min + ':' + sec + '.' + ms + ']'
