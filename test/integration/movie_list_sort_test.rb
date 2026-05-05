require 'test_helper'

class MovieListSortTest < ActionDispatch::IntegrationTest
  test "view movie list after adding 2 movies ordered alphabetically (imperative)" do
    # Given I am on the RottenPotatoes home page
    get movies_path
    assert_response :success
    
    # When I follow "Add new movie"
    get new_movie_path
    assert_response :success
    
    # When I fill in "Title" with "Zorro"
    post movies_path, params: {
      movie: {
        title: 'Zorro',
        rating: 2,
        description: 'A classic adventure film about a masked hero fighting injustice',
        release_date: '1920-01-28'
      }
    }
    assert_redirected_to movies_path
    follow_redirect!
    
    # When I follow "Add new movie" again
    get new_movie_path
    assert_response :success
    
    # When I fill in "Title" with "Apocalypse Now"
    post movies_path, params: {
      movie: {
        title: 'Apocalypse Now',
        rating: 5,
        description: 'An epic war film depicting the horrors and chaos of the Vietnam War',
        release_date: '1979-05-19'
      }
    }
    assert_redirected_to movies_path
    follow_redirect!
    
    # When I click "title" sort header
    get movies_path, params: { sort_by: 'title', sort_order: 'asc' }
    assert_response :success
    
    # Then "Apocalypse Now" should appear before "Zorro"
    body = response.body
    assert body.index('Apocalypse Now') < body.index('Zorro'), 
      "Apocalypse Now should appear before Zorro in the sorted list"
  end

  test "view movie list with 2 movies sorted alphabetically (declarative)" do
    # Given there are 2 movies
    Movie.create!(
      title: 'Apocalypse Now',
      rating: 5,
      description: 'An epic war film depicting the horrors and chaos of the Vietnam War',
      release_date: '1979-05-19'
    )
    
    Movie.create!(
      title: 'Zorro',
      rating: 2,
      description: 'A classic adventure film about a masked hero fighting injustice',
      release_date: '1920-01-28'
    )
    
    # When I go to the RottenPotatoes home page
    get movies_path
    
    # And I click "title" sort header
    get movies_path, params: { sort_by: 'title', sort_order: 'asc' }
    assert_response :success
    
    # Then "Apocalypse Now" should appear before "Zorro" in the movie list
    body = response.body
    assert body.index('Apocalypse Now') < body.index('Zorro'),
      "Apocalypse Now should appear before Zorro in the sorted list"
  end
end
