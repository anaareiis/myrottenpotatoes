require 'test_helper'

class MovieSearchTest < ActionDispatch::IntegrationTest
  test "sad path - try to add nonexistent movie" do
    # Test 1: Try to add nonexistent movie (sad path)
    get movies_path
    assert_response :success
    assert_select 'h3', 'Search TMDb for a movie'
    
    # POST search for nonexistent movie
    post search_tmdb_movies_path, params: { search_terms: 'Movie That Does Not Exist' }
    
    # Should redirect to home page with error message
    assert_redirected_to movies_path
    follow_redirect!
    
    # Check if error message appears
    assert_response :success
    assert_select '.alert-alert', { text: /Movie That Does Not Exist was not found in TMDb\./ }
  end
end
