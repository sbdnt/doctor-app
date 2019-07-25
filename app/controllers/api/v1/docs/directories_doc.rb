class Api::V1::Docs::DirectoriesDoc <  ActionController::Base
  def_param_group :directories do 
    param :type, Integer, desc: "1: Information or 2: Call Directory: integer", required: true
  end

  def self.index_desc
    <<-EOS
      Results of list Information
      {
        [
          {
              "id": 2,
              "title": "test 2",
              "kind": "Information",
              "elements": [
                  {
                      "id": 1,
                      "name": "erer",
                      "phone": "rere",
                      "address": "rer",
                      "working_days": []
                  }
              ]
          },
          {
              "id": 3,
              "title": "test3",
              "kind": "Information",
              "elements": [
                  {
                      "id": 4,
                      "name": "2",
                      "phone": "2",
                      "address": "2",
                      "working_days": [
                          {
                              "id": 1,
                              "close_at": "19:08",
                              "open_at": "05:06",
                              "element_id": 4,
                              "week_day": 1
                          }
                      ]
                  }
              ]
          }
        ]
      }

      Results of list Call Directory
      [
        {
            "id": 1,
            "title": "test 1",
            "kind": "Call Directly",
            "elements": [
                {
                    "id": 2,
                    "name": "a",
                    "phone": "b",
                    "address": "c"
                },
                {
                    "id": 3,
                    "name": "g",
                    "phone": "e",
                    "address": "q"
                }
            ]
        }
      ]
    EOS
  end
end