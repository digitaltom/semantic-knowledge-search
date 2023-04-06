[![Container build](https://github.com/digitaltom/knowledge/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/digitaltom/knowledge/pkgs/container/knowledge)

# Knowledge - Search related articles based on openai embedding, and answer with GPT

![2023-04-07_01-07](https://user-images.githubusercontent.com/582520/230509975-049c6b73-ae39-4a5d-9d64-aa31de04a0e0.png)

- Create small text files representing knowledge articles under `storage/training`.
  Example crawlers are `bin/doc_crawler.rb` and `bin/kb_crawler`.
  Format is: First line uri, second line title, third ff. content.
- Import articles with openai embedding vectors with:
  `Article.import_all(reindex: false)` (imports all from `storage/training/**/*.txt`) into sqlite.
- Find relevant articles with: `Question.new("question text").related_articles`
- Create answer with: `Answer.new(question, article).generate`

### Development

To run the app locally, `cssbundling-rails` requires to run `yarn build:css --watch`
in a second terminal next to `rails s`. For `jsbundling-rails`, you need to do the same with `yarn build --watch`. Those commands are combined in `Procfile.dev` and can be run
with `foreman start -f Procfile.dev`.


* Build image: `DOCKER_BUILDKIT=1 docker build -t ghcr.io/digitaltom/knowledge .`
* Run image: `docker run -ti --network=host --rm -e SECRET_KEY_BASE=<random_secret_key> -e OPENAI_API_KEY=<key> -v <path to storage/training>:/rails/storage/training -v <path to roduction.sqlite3>:/rails/db/production.sqlite3 ghcr.io/digitaltom/knowledge:latest`

