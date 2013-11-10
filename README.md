# Sourcery
Experimental event sourcing approach for Erlang.

## Concepts
Here's a breakdown of the primitives involved in this implementation:

### Event Sourced Actors
This approach borrows from event sourcing, CQRS and CRDT work done by others. It's not original, but perhaps a slightly different take on event sourcing. Comments and critique welcome.

### Events
An event is generated as a result of an actor processing a message (event or command). Actor mutation happens later as a result of applying one or more events against the actor.

Each event will have a correlation id to specify which actor it applies to, a unique k-ordered id, a timestamp and a initiated_by field to indicate what message triggered the event creation.

Any time an actor's present state is required (on read or on command process), events are loaded and ordered by time + event id (as a means to get some approximation of total ordering) and then applied to the last actor state to provide a 'best known current actor state'.

### Actors
An actor is identified by a unique id and a vector clock. Instead of mutating and persisting actor state after each message, actors generate events when processing a message. Before processing a message, an actor's last available persisted state is loaded from storage, all events generated since the actor was persisted are loaded and applied to the actor.

After some threshold of applied events is crossed, the resulting actor will be persisted with a new vector clock to prevent the number of events that need to be applied from becoming a bottleneck over time.

__The Importance of Isolation__
The expectation in this approach is that actors messages will be processed in isolation at both a node and process level. Another way to put this is that no two messages for an actor can be processed at the same time in a cluster. The exception to this assumption is network partitions. Read on to see how this approach deals with partitions.

### Divergent Replicas
In the event of a network partition, if messages are processed for the same actor on more than one partition, replicas will be created. These divergent replicas may result in multiple copies of the same actor which have divergent state. When this happens, multiple actors will be retrieved when the next message is processed.

To resolve this divergence, the system will walk the actors' ancestors to find the latest shared ancestor and apply all events that have occured since that ancestor to produce a 'correct' actor state.

### Ancestors
An ancestor is just a prior actor's state identified by the combination of the actor id and the vector clock. Ancestors exist primarily to resolve divergent replicas of an actor that will be created in the event of a network partition.

### Event Packs
Whenever an updated actor is persisted, all events that were applied to create the update will be stored as a single record identified by the actor's vector and id. Whenever divergent actors are being resolved, event packs will be loaded to provide a deterministic set of events to apply against the common ancestor.

### Vector Clocks
Due to the decreased frequency of actor persistence and the decrease in number of nodes that can participate in peristence of a particular actor, vector clock growth should be relatively tame*. This is the long-form of, "I am not planning to prune vector clocks, may they grow like the mighty oak."

*for imaginary values of tame; this is a naive conjecture :)

### k-ordered ids
I just liked saying k-ordered. It just means "use flake".

## If LWW Is All You Need
Event sourcing is a bit silly if you don't mind losing data. Chances are if LWW is fine then you're dealing with slowly changing dimensions that have very low probability of conflicting changes.

## If Only Strong Consistency Will Do
This will be supported one day. For now, you shouldn't use this library for this case. This library is intended to prioritize availability and partition tolerance and sacrifices consistency by throwing it straight out the window.

## Dependencies

### Persistent Storage - Riak

### Cache - Redis

### Durable Message Queues / Isolation - RabbitMQ

### Event Publishing - Topical 

### Id Generation - Flake