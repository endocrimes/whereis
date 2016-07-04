describe(LocationController) do
  let(:foursquare_client) { double(Foursquare2::Client) }

  before do
    @location_controller = LocationController.new(foursquare_client)
  end

  describe '#most_recent_location' do
    it 'should return a NilLocation when Foursquare fails' do
      allow(foursquare_client).to receive(:user_checkins)
        .with(limit: 1)
        .and_return(nil)
      expect(@location_controller.most_recent_location.class) == NilLocation
    end
  end
end
