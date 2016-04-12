class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      @alluserContent = current_user.contents.count

      unless @alluserContent.present?
        redirect_to channels_path, notice:"Please Sign on and pull some data!"
        return
      end

      # search_query = params[:q].presence || "*"
      # NEED TO DO SEARCH FROM BASE CLASS: DO NOT BUILD OFF alluserContent, REQUIRES 'WHERE' CLAUSE.
      # .order(:name).page params[:page]
      @userContent = Content.where(user_id: current_user.id).page(params[:page]).per(10)
      # @userContent = Content.search search_query, where:{user_id: current_user.id}, page: params[:page], per_page: 15

      # FOR THE MAP :D
      # GET ALL CONTENT OBJECTS FOR THE MAP DISPLAY
      # @mapContent = @alluserContent
      # # THIS IS FOR THE DISPLAY MAP
      # @geojson = Array.new
      # # raise @mapContent.to_yaml
      # # PUT CONTENTS ON MAP
      # if @mapContent.present?
      #   @mapContent.each do |content|
      #     unless (content.longitude.nil? || content.latitude.nil?) || (content.longitude == '0' || content.latitude == '0')

      #       if (content.provider == "twitter")
      #         marker_color = '#4099FF'
      #       elsif (content.provider == "foursquare")
      #         marker_color = '#FFCC00'
      #       elsif (content.provider == "facebook")
      #         marker_color = '#FFFFFF'
      #       elsif (content.provider == "fitbit")
      #         marker_color = '#f15038'
      #       elsif (content.provider == "github")
      #         marker_color = '#F1AC38'
      #       else
      #         marker_color = "#387C81"
      #       end

      #       @geojson << {
      #         type: 'Feature',
      #         geometry: {
      #           type: 'Point',
      #           coordinates: [
      #             content.longitude,
      #             content.latitude
      #           ]
      #         },
      #         properties: {
      #           title:
      #             if (content.title.present?)
      #               content.title.capitalize
      #             elsif (content.provider.present? && content.kind.present? && !content.body.present? )
      #               content.provider.capitalize + " " + content.kind.capitalize
      #             elsif (content.provider.present?)
      #               content.provider.capitalize
      #             else
      #               " "
      #             end,
      #           body:
      #             if (content.body.present?)
      #               content.body.capitalize

      #             elsif (content.kind.present?)
      #               content.kind.capitalize + " on " + content.created_at.strftime("%b %e, %Y")
      #             else
      #               " "
      #             end,
      #           external_link:
      #               content_path(content.id),
      #               # "http://blackboxapp.io/content/"+ content.id.to_s,
      #           image:
      #             if (content.image.present?)
      #               content.image
      #             else
      #               " "
      #             end,
      #           address:
      #             if (content.city.present? && content.state.present?)
      #               content.city + ", " + content.state
      #             elsif content.location.present?
      #               content.location
      #             end,
      #           :'marker-color' => marker_color,
      #           :'marker-size' => 'small'
      #         }
      #       }
      #     end
      #   end
      # end
    end
    respond_to do |format|
      format.html
      format.json { render json: @geojson }  # respond with the created JSON object
      format.csv { send_data @alluserContent.to_csv, filename: "Content_Timeline-#{Date.today}.csv" }
    end
  end
  private

end
