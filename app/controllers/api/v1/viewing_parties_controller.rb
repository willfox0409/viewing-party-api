class Api::V1::ViewingPartiesController < ApplicationController
  def create
    party = ViewingParty.create_with_invitees(viewing_party_params.to_h)

    if party.persisted?
      render json: ViewingPartySerializer.new(party), status: :created
    else
      render json: ErrorSerializer.format_errors_array(party.errors.full_messages, 422), status: :unprocessable_entity
    end
  end

  private

  def viewing_party_params
    params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, invitees: [])
  end
end