FROM mambaorg/micromamba:1.5.3

RUN micromamba install -y -n base \
  -c bioconda -c conda-forge \
  fastqc=0.12.1 trimmomatic=0.39 \
  salmon=1.10.2 \
  && micromamba clean --all --yes

WORKDIR /app

COPY test_rnaseq_pipeline.sh /app/test_rnaseq_pipeline.sh
COPY rnaseq_pipeline.sh /app/rnaseq_pipeline.sh

CMD ["bash", "/app/rnaseq_pipeline.sh", "/app/test_rnaseq_pipeline.sh"]