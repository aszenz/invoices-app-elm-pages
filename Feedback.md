# Feedback

## Questions

1. What exactly is `data`, is it a function to get a response, how is view related to it ?

## Design Remarks

1. Defining a route currently means it accepts all http methods, unless one manually checks and throws error on unexpected http methods in both data and action.

2. Head function doesn't take request 