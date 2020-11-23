import { Event, DurationEvent, FlowEvent } from '../types/EventInterfaces';
import { EventsPhase } from '../types/Phases';

/**
 * These tests are 50% about testing that the types are implemented correctly,
 * and 50% documenting how to handle mapping between Event types and subtypes
 * with and without EventsPhas literal.
 *
 * The tests rely on the @ts-expect-error pragma, which will pass the type check
 * if the following line has a type error, and will error if the following line is fine.
 */
describe('Event', () => {
  it('should allow constructing event objects using EventsPhase enum values', () => {
    // create a new flow event
    const event: DurationEvent = {
      ts: 1,
      ph: EventsPhase.DURATION_EVENTS_BEGIN,
    };

    // check that value is correct in runtime
    expect(event).toEqual({ ts: 1, ph: 'B' });
  });
  it('should not allow constructing event objects using wrong enum values', () => {
    // try to create a new flow event, should fail with TypeScript error
    // @ts-expect-error
    const event: DurationEvent = { ts: 1, ph: EventsPhase.INSTANT_EVENTS };

    // at runtime object is still created, but we should never be here
    expect(event).toEqual({ ts: 1, ph: 'I' });
  });

  it('should not allow constructing event objects with phase literal at type level', () => {
    // try to create a new flow event, should fail with TypeScript error
    // @ts-expect-error
    const event: DurationEvent = { ts: 'ts', ph: 's' };

    // check that value is correct in runtime
    expect(event).toEqual({ ts: 'ts', ph: 's' });
  });

  it('should not allow coercing event objects with incorrect phase literal', () => {
    // try to create a new flow event, should fail with TypeScript error
    // @ts-expect-error
    const event: DurationEvent = { ts: 'ts', ph: 'NOT_s' } as DurationEvent;

    // check that value is correct in runtime
    expect(event).toEqual({ ts: 'ts', ph: 'NOT_s' });
  });

  it('should allow polymorphic lists of different event types', () => {
    const flow: FlowEvent = { ts: 1, ph: EventsPhase.FLOW_EVENTS_END };
    const duration: DurationEvent = {
      ts: 1,
      ph: EventsPhase.DURATION_EVENTS_END,
    };

    // should not type error
    const events: Event[] = [flow, duration];

    expect(events).toEqual([
      { ts: 1, ph: 'f' },
      { ts: 1, ph: 'E' },
    ]);
  });

  it('should not allow polymorphic lists where any value is not a valid event type', () => {
    const durationEnd: DurationEvent = {
      ts: 1,
      ph: EventsPhase.DURATION_EVENTS_END,
    };
    const durationBegin: DurationEvent = {
      ts: 1,
      ph: EventsPhase.DURATION_EVENTS_BEGIN,
    };
    const invalid = {
      ts: 'ts',
      ph: 'invalid',
    };

    // @ts-expect-error
    const events: Event[] = [durationEnd, durationBegin, invalid];

    expect(events).toEqual([
      { ts: 1, ph: 'E' },
      { ts: 1, ph: 'B' },
      { ts: 'ts', ph: 'invalid' },
    ]);
  });

  it('should support type guards', () => {
    // If we want to ensure that a type is *actually* of the type
    // we want it to be instead of relying on type coercion/casting,
    // we can use a type guard
    //
    // See: https://www.typescriptlang.org/docs/handbook/advanced-types.html#user-defined-type-guards
    function isDurationEvent(event: any): event is DurationEvent {
      return (
        event.ph === EventsPhase.DURATION_EVENTS_BEGIN ||
        event.ph === EventsPhase.DURATION_EVENTS_END
      );
    }

    // This function expects a duration event
    function expectsDurationEvent(event: DurationEvent): any {
      return event.ph;
    }

    // This
    const durationEventLike = { ts: 1, ph: 'B' };

    // This fails, because string `B` is not coerced to EventsPhase
    // @ts-expect-error
    expectsDurationEvent(durationEventLike);

    // But if we use our type guard first...
    if (isDurationEvent(durationEventLike)) {
      // This will pass, because isDurationEvent type guard refines the type
      // by checking that the value matches the expected type
      expectsDurationEvent(durationEventLike);
    } else {
      // This will fail, because the value didn't match
      // @ts-expect-error
      expectsDurationEvent(durationEventLike);
    }
  });
});
