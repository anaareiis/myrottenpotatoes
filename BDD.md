# BDD Guide - RottenPotatoes

## Overview

This document centralizes the BDD delivery for the RottenPotatoes project. It describes the Gherkin scenarios, the files involved, the Cucumber/Capybara configuration, and the commands required to run and validate the tests.

The goal of the BDD suite is to verify two user-visible behaviors:

- Movie search in TMDb with sad path handling when the movie is not found.
- Adding and sorting the movie list by title, in both imperative and declarative versions.

## Delivery goals

| Requested goal | Status | Where it is implemented |
| --- | --- | --- |
| Implement only the sad path for the TMDb search feature. | Implemented | `features/add_movie_sad_path.feature` |
| Implement the imperative scenario for adding two movies and sorting by title. | Implemented | `features/view_sorted_movies.feature` |
| Convert the imperative scenario to declarative style. | Implemented | `features/view_sorted_movies.feature` |

## Implemented structure

### Features

| File | Purpose |
| --- | --- |
| `features/add_movie_sad_path.feature` | Validates the TMDb search flow for a nonexistent movie. |
| `features/view_sorted_movies.feature` | Validates alphabetical movie sorting by title. |

### Test support

| File | Purpose |
| --- | --- |
| `features/step_definitions/movie_steps.rb` | Implements the steps used by the BDD scenarios. |
| `features/support/env.rb` | Loads Cucumber/Rails, disables controller rescue, and cleans the database between scenarios. |
| `cucumber.yml` | Defines the default profile with `pretty` output, an HTML report in `tmp/cucumber.html`, and quiet publishing. |

### Complementary Rails tests

| File | Purpose |
| --- | --- |
| `test/integration/movie_search_test.rb` | Validates the TMDb search sad path at the Rails integration level. |
| `test/integration/movie_list_sort_test.rb` | Validates title sorting with Rails integration tests. |

### Rails code exercised by the scenarios

| File | BDD-related change |
| --- | --- |
| `config/routes.rb` | Adds `POST /movies/search_tmdb` inside `resources :movies`. |
| `app/controllers/movies_controller.rb` | Implements `search_tmdb` and keeps sorting by `title` and `release_date`. |
| `app/views/movies/index.html.erb` | Displays the "Search TMDb for a movie" form and sorting links. |
| `Gemfile` | Includes test dependencies for Cucumber, Capybara, and DatabaseCleaner. |

## Delivery checklist

### BDD files

- `features/add_movie_sad_path.feature`: sad path scenario for TMDb search.
- `features/view_sorted_movies.feature`: imperative scenario and declarative scenario for sorting.
- `features/step_definitions/movie_steps.rb`: step definitions for navigation, forms, sorting, and data creation.
- `features/support/env.rb`: Cucumber/Rails environment configuration.
- `cucumber.yml`: test output configuration.

### Rails integration tests

- `test/integration/movie_search_test.rb`: covers the nonexistent TMDb search and the error message.
- `test/integration/movie_list_sort_test.rb`: covers creating two movies and sorting alphabetically by title.

### Rails changes

- `Gemfile`: BDD/test dependencies added.
- `config/routes.rb`: `POST /movies/search_tmdb` route.
- `app/controllers/movies_controller.rb`: `search_tmdb` action and support for sorting by title.
- `app/views/movies/index.html.erb`: TMDb search form and sorting headers.

### Documentation

- `BDD.md`: single document with technical guide, execution instructions, delivery checklist, and scenario summary.

## BDD scenarios

### 1. TMDb search - sad path

File: `features/add_movie_sad_path.feature`

This scenario ensures that, when searching for a nonexistent movie, the application returns to the home page and shows a clear error message.

```gherkin
Feature: User can add movie by searching for it in The Movie Database (TMDb)
  As a movie fan
  So that I can add new movies without manual tedium
  I want to add movies by looking up their details in TMDb

  Background: Start from the Search form on the home page
    Given I am on the RottenPotatoes home page
    Then I should see "Search TMDb for a movie"

  Scenario: Try to add nonexistent movie (sad path)
    When I fill in "Search Terms" with "Movie That Does Not Exist"
    And I press "Search TMDb"
    Then I should be on the RottenPotatoes home page
    And I should see "Movie That Does Not Exist was not found in TMDb."
```

Expected behavior:

- The search form appears on the home page.
- The user fills in the `Search Terms` field.
- The controller receives the request in `search_tmdb`.
- The application redirects to `movies_path`.
- The message `Movie That Does Not Exist was not found in TMDb.` is displayed.

### 2. Sort by title - imperative scenario

File: `features/view_sorted_movies.feature`

The imperative scenario describes the full UI flow step by step. It creates the movies the way a real user would: opens the creation page, fills in the fields, saves each movie, and then clicks the `Title` header to sort.

Movies used:

| Title | Rating | Release date |
| --- | --- | --- |
| Zorro | PG | 1920-01-28 |
| Apocalypse Now | R | 1979-05-19 |

Main validation:

```gherkin
When I click "title" sort header
Then I should see "Apocalypse Now" before "Zorro"
```

This format is more detailed and documents the UI path well, but it tends to be longer and more sensitive to interface changes.

### 3. Sort by title - declarative scenario

File: `features/view_sorted_movies.feature`

The declarative scenario expresses the business requirement with fewer interface details. The movies are created directly through a Gherkin table, and the test focuses on the main expectation: when sorted by title, `Apocalypse Now` should appear before `Zorro`.

```gherkin
Given there are 2 movies with the following details:
  | Title           | Rating | Description                                                     | Release date |
  | Apocalypse Now  | R      | An epic war film depicting the horrors and chaos of the Vietnam | 1979-05-19   |
  | Zorro           | PG     | A classic adventure film about a masked hero fighting injustice | 1920-01-28   |
When I go to the RottenPotatoes home page
And I click "title" sort header
Then "Apocalypse Now" should appear before "Zorro" in the movie list
```

This format is more concise, more readable as a specification, and less coupled to the screen-by-screen flow.

## Step definitions

The steps in `features/step_definitions/movie_steps.rb` cover four main groups:

### Navigation

- `Given('I am on the RottenPotatoes home page')`
- `When('I go to the RottenPotatoes home page')`
- `Then('I should be on the RottenPotatoes home page')`
- `Then('I should be on the Create New Movie page')`

### Interface interaction

- `When('I fill in {string} with {string}')`
- `When('I select {string} from {string}')`
- `When('I press {string}')`
- `When('I follow {string}')`
- `When('I click {string} sort header')`

### Content and order assertions

- `Then('I should see {string}')`
- `Then('I should see {string} before {string}')`
- `Then('{string} should appear before {string} in the movie list')`

### Declarative data creation

- `Given('there are {int} movies with the following details:')`

This step reads the Gherkin table, converts ratings such as `PG` and `R` to the values used by the application, and creates the records with `Movie.create!`.

## BDD environment configuration

### Dependencies

The relevant gems for the BDD tests are:

- `cucumber`
- `cucumber-rails`
- `capybara`
- `selenium-webdriver`
- `database_cleaner-active_record`
- `rack-test`

### `features/support/env.rb`

The support configuration does three important things:

- Loads the Cucumber and Rails integration with `require 'cucumber/rails'`.
- Sets `ActionController::Base.allow_rescue = false`, allowing controller errors to appear directly in the tests.
- Uses `DatabaseCleaner.strategy = :transaction` and `DatabaseCleaner.cleaning` to isolate the scenarios.

### `cucumber.yml`

The default profile runs the scenarios with readable terminal output and generates an HTML report:

```yaml
default: --format pretty --format html --out tmp/cucumber.html --publish-quiet
```

## How to run

### Prepare the environment

```bash
bundle install
RAILS_ENV=test bundle exec rails db:test:prepare
```

### Run all BDD scenarios

```bash
bundle exec cucumber
```

### Run the related Rails integration tests

```bash
bundle exec rails test test/integration/movie_search_test.rb test/integration/movie_list_sort_test.rb
```

### Run specific features

```bash
bundle exec cucumber features/add_movie_sad_path.feature
bundle exec cucumber features/view_sorted_movies.feature
```

### Generate or update the HTML report

The report is already generated by the default profile at:

```text
tmp/cucumber.html
```

It can also be called explicitly:

```bash
bundle exec cucumber --format pretty --format html --out tmp/cucumber.html
```

## Acceptance criteria

The BDD delivery is complete when:

- `bundle exec cucumber` runs all three scenarios.
- The related integration tests pass with `bundle exec rails test test/integration/movie_search_test.rb test/integration/movie_list_sort_test.rb`.
- The TMDb scenario displays the movie-not-found message and returns to the home page.
- The imperative scenario adds both movies through the interface and validates alphabetical order.
- The declarative scenario creates data through a table and validates the same sorting rule.
- The test database is cleaned between scenarios, avoiding execution order dependencies.

## Relevant final structure

```text
myrottenpotatoes/
├── features/
│   ├── add_movie_sad_path.feature
│   ├── view_sorted_movies.feature
│   ├── step_definitions/
│   │   └── movie_steps.rb
│   └── support/
│       └── env.rb
├── app/
│   ├── controllers/
│   │   └── movies_controller.rb
│   └── views/
│       └── movies/
│           └── index.html.erb
├── config/
│   └── routes.rb
├── test/
│   └── integration/
│       ├── movie_list_sort_test.rb
│       └── movie_search_test.rb
├── BDD.md
├── cucumber.yml
├── Gemfile
└── Gemfile.lock
```

## Tools and concepts demonstrated

### Tools

- Cucumber/Cucumber Rails for writing and running BDD scenarios.
- Capybara for simulating user navigation and interaction with the application.
- Selenium WebDriver as a browser automation dependency.
- DatabaseCleaner for isolating data between scenarios.
- Gherkin for describing behavior with `Feature`, `Background`, `Scenario`, `Given`, `When`, `Then`, and tables.

### BDD concepts

- User story focused on user value.
- Sad path for validating error handling.
- Imperative scenario for documenting the detailed UI flow.
- Declarative scenario for expressing the business rule with less interface coupling.
- Gherkin tables for creating structured data.
- Separation between specification (`.feature`) and automation (`step_definitions`).

## Quantitative summary

| Item | Quantity |
| --- | --- |
| BDD features | 2 |
| BDD scenarios | 3 |
| Main Cucumber support files | 3 |
| Related Rails integration tests | 2 |
| Rails routes added | 1 |
| Controller actions added | 1 |
| Consolidated delivery document | 1 |

## Suggested video demonstration

1. Briefly present `BDD.md` and the three delivery goals.
2. Show `features/add_movie_sad_path.feature` and explain the sad path.
3. Show `features/view_sorted_movies.feature` comparing the imperative and declarative scenarios.
4. Run `bundle exec cucumber`.
5. Open `tmp/cucumber.html`, if the report has been generated.
6. Start the application with `bundle exec rails server` and demonstrate the TMDb search and title sorting.

## Maintenance notes

- Prefer declarative scenarios for stable business rules.
- Use imperative scenarios when the UI flow is also an important part of the specification.
- When changing labels, field names, or button text, review the mappings in `movie_steps.rb`.
- When changing the ratings model, review the conversion performed by the steps that use `PG` and `R`.
