#!/bin/bash

# Gets the dependencies, compiles the library and runs the tests.
# If the tests pass then it also generates a custom bit of
# documentation from a test file

LOCATION=doc-extras/showcase.md
SHOWCASE_TEST=test/concrete_optics_test.exs

touch $LOCATION
echo '# Showcase' > $LOCATION
echo '' >> $LOCATION
echo '```elixir' >> $LOCATION
cat $SHOWCASE_TEST >> $LOCATION
echo '```' >> $LOCATION
echo '' >> $LOCATION
mix deps.get
mix compile
echo "Testing" $SHOWCASE_TEST
mix test $SHOWCASE_TEST
TEST_STATUS=$?
if [ $TEST_STATUS -eq 0 ]; then
    mix docs --formatter html --output docs
else
    echo "❌ Showcase test failed, not producing showcase document. ❌"
    exit $TEST_STATUS
fi
