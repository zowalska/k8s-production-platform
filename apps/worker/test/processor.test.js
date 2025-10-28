'use strict';

jest.mock('../src/db', () => ({
  markTaskStatus: jest.fn().mockResolvedValue(),
  ping: jest.fn(),
  pool: { end: jest.fn() },
}));

const db = require('../src/db');
const processTask = require('../src/processor');

describe('processTask', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('processes a task successfully and marks it completed', async () => {
    const job = { id: '1', data: { taskId: 42, payload: { workMs: 1 } } };

    const result = await processTask(job);

    expect(result.workMs).toBe(1);
    expect(db.markTaskStatus).toHaveBeenCalledWith(
      42,
      'completed',
      expect.objectContaining({ workMs: 1 }),
    );
  });

  test('throws and does not mark completed when simulateFailure is set', async () => {
    const job = { id: '2', data: { taskId: 43, payload: { simulateFailure: true } } };

    await expect(processTask(job)).rejects.toThrow('simulated task failure');
    expect(db.markTaskStatus).not.toHaveBeenCalled();
  });
});
