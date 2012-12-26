
The volume code in this directory needs some work.

With various values for:

a) Min/max number of tests
b) Min/Max number of STOMP clients/connections
c) Min/Max number of messages

this code can:

a) Hang (in the driver join loop)
b) Take broken pipe exceptions (Client publish)

Analysis: TBD

Fix: TBD

