#!/bin/bash

LOCATION=doc-extras/showcase.md
SHOWCASE_TEST=test/concrete_optics_showcase_test.exs

touch $LOCATION
echo '# Showcase' > $LOCATION
echo '' >> $LOCATION
echo '```elixir' >> $LOCATION
cat $SHOWCASE_TEST >> $LOCATION
echo '```' >> $LOCATION
echo '' >> $LOCATION
mix deps.get
mix compile
mix test $SHOWCASE_TEST
TEST_STATUS=$?
if [ $TEST_STATUS -eq 0 ]; then
    mix docs --formatter html --output docs
else
    echo "❌ Showcase tests failed, not producing showcase document. ❌"
    exit $TEST_STATUS
fi
