#!/bin/bash

LOCATION=doc-extras/showcase.md

touch $LOCATION
echo '# Showcase' > $LOCATION
echo '' >> $LOCATION
echo '```elixir' >> $LOCATION
cat test/concrete_optics_test.exs >> $LOCATION
echo '```' >> $LOCATION
echo '' >> $LOCATION
mix deps.get
mix compile
mix docs --formatter html --output docs
