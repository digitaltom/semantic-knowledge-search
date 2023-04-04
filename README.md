# Knowledge - Search related articles based on openai embedding, and answer with GPT

![image](https://user-images.githubusercontent.com/582520/227728425-a407d4a7-951d-4f32-8bc4-cb405919571c.png)

- Create small text files representing knowledge articles under `storage/training`.
  Example crawlers are `bin/doc_crawler.rb` and `bin/kb_crawler`.
  Format is: First line uri, second line title, third ff content.
- Import articles with openai embedding vectors with:
  `Article.import_all` (imports all from `storage/training/**/*.txt`)
- Get relevant articles with: `Question.new("question text").related_articles`
- Create answer with: `Answer.new(question, article).generate`

### Development

Build image: `DOCKER_BUILDKIT=1 docker build -t ghcr.io/digitaltom/knowledge .`
Run image: `docker run -ti --network=host --rm -e SECRET_KEY_BASE=<random_secret_key> -e OPENAI_API_KEY=<key> -v /space/workspace/knowledge/storage/training:/rails/storage/training -v /space/workspace/knowledge/db/production.sqlite3:/rails/db/production.sqlite3 ghcr.io/digitaltom/knowledge:latest`
