'use strict';

jest.mock('../src/queue', () => ({
  queue: { getJobCounts: jest.fn() },
  connection: { ping: jest.fn(), quit: jest.fn() },
  ping: jest.fn(),
}));

const { queue } = require('../src/queue');
const { pollOnce, STATES } = require('../src/metrics-poller');
const { register } = require('../src/metrics');

describe('metrics-poller', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('pollOnce sets the worker_queue_jobs gauge for every state', async () => {
    queue.getJobCounts.mockResolvedValueOnce({
      waiting: 12,
      active: 3,
      delayed: 0,
      completed: 100,
      failed: 2,
    });

    const counts = await pollOnce();

    expect(queue.getJobCounts).toHaveBeenCalledWith(...STATES);
    expect(counts.waiting).toBe(12);

    const metrics = await register.getMetricsAsJSON();
    const gauge = metrics.find((m) => m.name === 'worker_queue_jobs');
    const waitingSample = gauge.values.find((v) => v.labels.state === 'waiting');
    expect(waitingSample.value).toBe(12);
  });
});
