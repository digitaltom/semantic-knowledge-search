[![Container build](https://github.com/digitaltom/semantic-knowledge-search/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/digitaltom/semantic-knowledge-search/pkgs/container/knowledge)

# Semantic knowledge search

Search engine to find related articles based on vector search, and create an
answer with GPT. Currently using openai APIs to create the embeddings and
GPT answer. In the future, the goal is to have a LLM embedded and run stand alone.

```mermaid
sequenceDiagram;
    actor User
    participant Semantic Search App
    participant openAI API
    loop Resource indexing
        Semantic Search App->>Project Doc Pages: Crawling page
        Project Doc Pages-->>Semantic Search App: Page content
        Semantic Search App->>openAI API: Request vector representation of content
        openAI API-->>Semantic Search App: Article vectors
        Semantic Search App->>Semantic Search App: Storing vectorized article in Sqlite VSS
    end        

    User->>Semantic Search App: Search request
    Semantic Search App->>openAI API: Request to vectorize question
    openAI API-->>Semantic Search App: Question vectors
    Semantic Search App->>Semantic Search App: Local vector similarity search based on vectorized articles
    Semantic Search App->>openAI API: Request GPT answer for question based on best matching article
    openAI API-->>Semantic Search App: GPT response
    Semantic Search App-->>User: Page with matching articles and GPT response
```

An installation with SUSE documentation + knowledge base articles as
data source is available at: https://geeko.port0.org/

![2023-04-13_12-04](https://user-images.githubusercontent.com/582520/231726466-d4e54b1d-4c8b-4a33-9596-e8d27cadbfd3.png)

### Running an instance of semantic search:

To start an instance of the search app run (replace <secret_key>, <openai_key>,
<path_to_production.sqlite3> with your own values):

`docker run -ti --network=host --rm -e SECRET_KEY_BASE=<random_secret_key> -e OPENAI_API_KEY=<openai_key> -v <path_to_production.sqlite3>:/rails/db/production.sqlite3 -name knowledge ghcr.io/digitaltom/semantic-knowledge-search`

Exec into the container with `docker exec -ti knowledge /bin/bash` to perform some tasks manually:

- Import articles with and create openai embedding vectors with:
  - `bin/rake log:info import:doc[url]` (import page from url)
  - `bin/rake log:info import:crawl[url]` (crawl articles based on `config/sites.yml`)
- Find relevant articles with: `Question.new("question text").related_articles`
- Create answer with: `Answer.new(question, article).generate`

### Development

To run the app locally, `cssbundling-rails` requires to run `yarn build:css --watch` in a second terminal next to `rails s`. For `jsbundling-rails`, you need to do the same with `yarn build --watch`. Those commands are combined in `Procfile.dev` and can be run with `foreman start -f Procfile.dev`.

To use the [SQLite VSS](https://github.com/asg017/sqlite-vss) (SQLite Vector Similarity Search) extension, you need to install the packages `libgomp1, libblas3, liblapack3` (see Dockerfile).

To build the container image run: `DOCKER_BUILDKIT=1 docker build -t ghcr.io/digitaltom/semantic-knowledge-search .`

### Related articles

* https://simonwillison.net/2023/Jan/13/semantic-search-answers/
* [Metadata filtering in vector similarity search](https://www.pinecone.io/learn/vector-search-filtering/)

