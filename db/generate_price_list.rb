# Generate price list
puts "-----Generating price list------"
PriceList.find_or_create_by(name: "Monday - Friday", description: "", price: 119, order: 1, price_type: "weekday")
PriceList.find_or_create_by(name: "Saturday - Sunday", description: "", price: 149, order: 2, price_type: "weekend")
PriceList.find_or_create_by(name: "Bank holidays", description: "", price: 200, order: 3, price_type: "bank_fee")
PriceList.find_or_create_by(name: "Extras", description: "", price: 5, order: 4, price_type: "extra")
PriceList.find_or_create_by(name: "Drug delivery", description: "Price dependent on prescription", order: 5, price_type: "drug_delivery")
PriceList.find_or_create_by(name: "", description: "Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in the place", price: nil, order: 6, price_type: "price_desc")
puts "-----End Generating price list------"

puts "-----Generating extra fees------"
ExtraFee.find_or_create_by(name: "Weekday", price: 15, extra_type: "weekday")
ExtraFee.find_or_create_by(name: "Weekend", price: 20, extra_type: "weekend")
ExtraFee.find_or_create_by(name: "Bank Holiday", price: 25, extra_type: "bank_fee")
puts "-----End Generating extra fees------"