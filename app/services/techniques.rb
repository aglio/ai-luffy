class Techniques < RubyLLM::Tool
  description "Gets a list of luffy's techniques"

  def execute
    url = "https://api.api-onepiece.com/v2/luffy-techniques/en"

    response = Faraday.get(url)
    data = JSON.parse(response.body)
  rescue => e
    { error: e.message }
  end
end
