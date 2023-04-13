[![Container build](https://github.com/digitaltom/knowledge/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/digitaltom/knowledge/pkgs/container/knowledge)

# Knowledge - Search related articles based on openai embedding, and answer with GPT

![2023-04-07_01-07](https://user-images.githubusercontent.com/582520/230509975-049c6b73-ae39-4a5d-9d64-aa31de04a0e0.png)

- Import articles with and create openai embedding vectors with:
  - `rake log:info import:doc` (import all doc pages)
  - `rake log:info import:doc[url]` (import page from url)
  - `rake log:info import:kb` (import knowledge base articles)
  - `Article.vectorize_all(reindex: false)` (vectorize articles)
- Find relevant articles with: `Question.new("question text").related_articles`
- Create answer with: `Answer.new(question, article).generate`

### Development

To run the app locally, `cssbundling-rails` requires to run `yarn build:css --watch`
in a second terminal next to `rails s`. For `jsbundling-rails`, you need to do the same with `yarn build --watch`. Those commands are combined in `Procfile.dev` and can be run
with `foreman start -f Procfile.dev`.


* Build image: `DOCKER_BUILDKIT=1 docker build -t ghcr.io/digitaltom/knowledge .`
* Run image: `docker run -ti --network=host --rm -e SECRET_KEY_BASE=<random_secret_key> -e OPENAI_API_KEY=<key> -v <path to production.sqlite3>:/rails/db/production.sqlite3 ghcr.io/digitaltom/knowledge`
* Exec into container: `docker exec knowledge /bin/bash`

### Related articles

* https://simonwillison.net/2023/Jan/13/semantic-search-answers/

