class Api::V1::InvitationsController < ApplicationController
  def create
    party = Invitation.add_user_to_party(params[:viewing_party_id], params[:invitees_user_id])
    render json: ViewingPartySerializer.new(party), status: :created
  end
end