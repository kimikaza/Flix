json.success false
json.error do
  json.status @status[:code]
  json.status_text @status[:text]
  json.message @message
end