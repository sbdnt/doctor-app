class InvoicesController < ApplicationController
  def get_price_items
    result = {}
    if params[:price_category_id].present?
      price_category = PriceCategory.find_by_id( params[:price_category_id] )
      item_lists = []
      price_item_list = price_category.price_items.where(is_default: false).order("name")
      price_item_list.map{ |i| item_lists << {:id => i.id, :text => i.name} } if price_item_list.size > 0
      id_name = params[:id_name].gsub('category_id','id')
      result = { id_name: id_name, item_lists: item_lists }
    end

    render :json => result
  end

  def get_item_price
    result = {}
    if params[:price_item_id].present?
      price = PriceItem.find_by_id(params[:price_item_id]).try(:price_per_unit)
      result = { price: price}
    end

    render :json => result
  end
end