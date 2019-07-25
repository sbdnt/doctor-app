class Api::V1::DirectoriesController < Api::V1::BaseApiController

  api :GET, '/directories', 'Get list of directories'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :directories, Api::V1::Docs::DirectoriesDoc
  example Api::V1::Docs::DirectoriesDoc.index_desc
  def index
    required :type, :auth_token
    if params[:type].to_i == Category::CALL
      render json: Category.get_call_directories
    else
      render json: Category.get_informations
    end
  end
end
