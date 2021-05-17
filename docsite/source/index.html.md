---
title: Introduction
layout: gem-single
type: gem
name: dry-view
sections:
  - configuration
  - injecting-dependencies
  - exposures
  - templates
  - parts
  - scopes
  - context
  - testing
---

dry-view is a complete, standalone view rendering system that gives you everything you need to write well-factored view code.

Use dry-view if:

- You recognize that view code can be complex, and want to work with a system that allows you to break your view logic apart into sensible units
- You want to be able to [unit test](docs::testing) all aspects of your views, in complete isolation
- You want to maintain a sensible separation of concerns between the layers of functionality within your app
- You want to build and render views in any kind of context, not just when serving HTTP requests
- You're using a lightweight routing DSL like Roda or Sinatra and you want to keep your routes clean and easy to understand (dry-view handles the integration with your application, so all you need to provide from routes is the user-provided input params)
- Your application structure supports dependency injection as the preferred way to share behaviour between components (e.g. dry-view fits perfectly with [dry-system](/gems/dry-system), [dry-container](/gems/dry-container), and [dry-auto_inject](/gems/dry-auto_inject))

## Concepts

dry-view divides the responsibility of view rendering across several different components:

- The **View**, representing a view in its entirety, holding its configuration as well as any application-provided dependencies
- [**Exposures**](docs::exposures), defined as part of the view, declare the values that should be exposed to the template, and how they should be prepared
- [**Templates** and **partials**](docs::templates), which contain the markup, code, and logic that determine the view's output. Templates may have different **formats**, which act as differing representations of a given view
- [**Parts**](docs::parts), which wrap the values exposed to the template and provide a place to encapsulate view-specific behavior along with particular values
- [**Scopes**](docs::scopes), which offer a place to encapsulate view-specific behaviour intended for a particular _template_ and its complete set of values
- [**Context**](docs::context), a single object providing the baseline environment for a given rendering, with its methods made available to all templates, partials, parts, and scopes

## Example

[Configure](docs::configuration) your view, accept some [dependencies](docs::injecting-dependencies), and define an [exposure](docs::exposures):

```ruby
require "dry/view"

class ArticleView < Dry::View
  config.paths = [File.join(__dir__, "templates")]
  config.part_namespace = Parts
  config.layout = "application"
  config.template = "articles/show"

  attr_reader :article_repo

  def initialize(article_repo:)
    @article_repo = article_repo
    super
  end

  expose :article do |slug:|
    article_repo.by_slug(slug)
  end
end
```

Write a layout (`templates/layouts/application.html.erb`):

```erb
<html>
  <body>
    <%= yield %>
  </body>
</html>
```

And a [template](docs::templates) (`templates/articles/show.html.erb`):

```erb
<h1><%= article.title %></h1>
<p><%= article.byline_text %></p>
```

Define a [part](docs::parts) to provide view-specific behavior around the exposed `article` value:

```ruby
module Parts
  class Article < Dry::View::Part
    def byline_text
      authors.map(&:name).join(", ")
    end
  end
end
```

Then `#call` your view to render the output:

```ruby
view = ArticleView.new
view.call(slug: "cheeseburger-backpack").to_s
# => "<html><body><h1>Cheeseburger Backpack</h1><p>Rebecca Sugar, Ian Jones-Quartey</p></body></html>
```

`Dry::View::#call` expects keyword arguments for input data. These arguments are handled by your [exposures](docs::exposures), which prepare [view parts](docs::parts) that are passed to your [template](docs::templates) for rendering.
