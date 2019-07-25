class Api::V1::Docs::Doctors::ChargesDoc <  ActionController::Base

  def self.charges
    <<-EOS
    Author: Thanh
    Updated by: Thai 09/21/2015
    GET http://gpdq.co.uk/api/v1/doctors/charges
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA"}
      ===> there is 1 case:
      - List categories and items - Status 200:
      {
        "categories": [
          {
            "uid": 4,
            "name": "Paid for Drugs",
            "allow_expand": true,
            "allow_edit_price": false,
            "items": [
              {
                "uid": 5,
                "name": "Drug 1",
                "price_per_unit": 10,
                "quantity": 1,
                "category_id": 4,
                "is_default": false,
                "editable": true,
                "desc": ""
              },
              {
                "uid": 6,
                "name": "Drug 2",
                "price_per_unit": 20,
                "quantity": 1,
                "category_id": 4,
                "is_default": false,
                "desc": ""
              },
              {
                "uid": 7,
                "name": "Drug 3",
                "price_per_unit": 30,
                "quantity": 1,
                "category_id": 4,
                "is_default": false,
                "desc": ""
              }
            ]
          },
          {
            "uid": 5,
            "name": "Paid for Testing",
            "allow_expand": true,
            "allow_edit_price": false,
            "items": [
              {
                "uid": 10,
                "name": "ADHD/Attention Deficit Disorder Test",
                "price_per_unit": 50,
                "quantity": 1,
                "category_id": 5,
                "is_default": false,
                "desc": "Is your work, home life, or any other area suffering as a result of attention problems? - See more at: http://www.queendom.com/tests/testscontrol.htm?s=76#sthash.YmGT5aVN.dpuf"
              },
              {
                "uid": 11,
                "name": "Anger Management Test",
                "price_per_unit": 50,
                "quantity": 1,
                "category_id": 5,
                "is_default": false,
                "desc": "Do you deal with situations that anger you in a healthy way? - See more at: http://www.queendom.com/tests/testscontrol.htm?s=76#sthash.YmGT5aVN.dpuf"
              },
              {
                "uid": 12,
                "name": "Anxiety Test",
                "price_per_unit": 50,
                "quantity": 1,
                "category_id": 5,
                "is_default": false,
                "desc": "Anxiety can seriously inhibit your ability to function and can really hold you back from doing stuff you love. - See more at: http://www.queendom.com/tests/testscontrol.htm?s=76#sthash.YmGT5aVN.dpuf"
              },
              {
                "uid": 13,
                "name": "Attention Span Test",
                "price_per_unit": 50,
                "quantity": 1,
                "category_id": 5,
                "is_default": false,
                "desc": "Does your attention span last for hours, or does the smallest distraction pull you away? - See more at: http://www.queendom.com/tests/testscontrol.htm?s=76#sthash.YmGT5aVN.dpuf"
              },
              {
                "uid": 14,
                "name": "Brief Mental Health Evaluation",
                "price_per_unit": 50,
                "quantity": 1,
                "category_id": 5,
                "is_default": false,
                "desc": "Concerned about your mental health? This evaluation screens for the most common disorders - See more at: http://www.queendom.com/tests/testscontrol.htm?s=76#sthash.Y0CtHhV0.dpuf"
              }
            ]
          },
          {
            "uid": 6,
            "name": "Tax",
            "allow_expand": true,
            "allow_edit_price": true,
            "items": [
              {
                "uid": 17,
                "name": "Tax 100$",
                "price_per_unit": 100,
                "quantity": 1,
                "category_id": 6,
                "is_default": false,
                "desc": ""
              }
            ]
          }
        ]
      }
    EOS
  end

  def self.charges_with_appointment
    <<-EOS
      GET http://gpdq.co.uk/api/v1/doctors/charges_with_appointment
        PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "appointment_id" => "100"}
        ===> there is 1 case:
        - List categories and items - Status 200:

        {
        "categories": [
          {
            "uid": 18,
            "name": "Consultation",
            "items": [
              {
                "uid": 28,
                "name": "Consultation",
                "price_per_unit": 119,
                "quantity": 1,
                "category_id": 18,
                "is_default": false,
                "editable": false,
                "desc": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam pharetra, arcu ut convallis condimentum, lectus enim suscipit velit, vel efficitur urna velit eget elit. Suspendisse eu imperdiet orci. Pellentesque in libero sed ipsum molestie lobortis quis eget massa. Donec pellentesque dignissim sollicitudin. Nullam laoreet tempus interdum. Vestibulum vel purus tellus. Etiam vitae maximus nulla. Quisque ullamcorper malesuada sem, non sodales orci posuere in."
              }
            ],
            "allow_expand": false,
            "allow_edit_price": false,
            "allow_patient_expand": false
          },
          {
            "uid": 13,
            "name": "Drugs Delivery",
            "items": [
              {
                "uid": 24,
                "name": "Drugs Delivery",
                "price_per_unit": "0.0",
                "quantity": 1,
                "category_id": 13,
                "is_default": false,
                "editable": true,
                "desc": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam pharetra, arcu ut convallis condimentum, lectus enim suscipit velit, vel efficitur urna velit eget elit. Suspendisse eu imperdiet orci. Pellentesque in libero sed ipsum molestie lobortis quis eget massa. Donec pellentesque dignissim sollicitudin. Nullam laoreet tempus interdum. Vestibulum vel purus tellus. Etiam vitae maximus nulla. Quisque ullamcorper malesuada sem, non sodales orci posuere in."
              }
            ],
            "allow_expand": true,
            "allow_edit_price": true,
            "allow_patient_expand": false
          },
          {
            "uid": 19,
            "name": "Voucher",
            "items": [
              {
                "uid": 32,
                "name": "Voucher",
                "price_per_unit": 0.00,
                "quantity": 1,
                "item_type": "voucher",
                "discount": "10%",
                "category_id": 19,
                "is_default": false,
                "editable": false,
                "desc": ""
              }
            ],
            "allow_expand": false,
            "allow_edit_price": false,
            "allow_patient_expand": false
          }
        ]
      }
    EOS
  end
end