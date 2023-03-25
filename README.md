# Knowledge - Search related articles based on openai embedding, and answer with GPT

- Create small text files representing knowledge articles under `storage/training`.
  Example crawlers are `bin/doc_crawler.rb` and `bin/kb_crawler`.
  Format is: First line uri, second line title, third ff content.
- Import articles with openai embedding vectors with:
  `Article.import_all` (imports all from `storage/training/**/*.txt`)
- Get relevant articles with: `Question.new("question text").related_articles`
- Create answer with: `Answer.new(question, article).generate`

## CLI tool

```
> bin/openai_prompt.rb --help
Usage: --help [options]
    -q, --question QUESTION          Provide question as parameter
    -m, --mode MODE                  Mode [default|ruby]
    -d, --debug                      Debug mode
    -l, --lang
```
