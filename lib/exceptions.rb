module Exceptions
  class ApiParameterMissing < KeyError
    def initialize(params, message='')
      @params = params
      build_message(message)
    end

    def build_message(message)
      if message.blank?
        if @params.size == 1
          @message = I18n.t("controller.common.missing_params", key: @params[0])
        else
          @message = I18n.t("controller.common.missing_params")
        end
      else
        @message = message
      end
    end

    def to_json(options={})
      error = ""
      # @params.each do |param|
      error = "#{@params[0].to_sym} can't be blank"
      # end
      {message: @message, errors: error}.merge(options)
    end
  end

  class NotFoundUploadType < KeyError

  end
end
