'use strict';

const { metricsHandler, register } = require('../src/metrics');

describe('metrics', () => {
  test('metricsHandler writes the prometheus registry content type and body', async () => {
    const res = {
      headers: {},
      setHeader(key, value) {
        this.headers[key] = value;
      },
      end: jest.fn(),
    };

    await metricsHandler({}, res);

    expect(res.headers['Content-Type']).toBe(register.contentType);
    expect(res.end).toHaveBeenCalled();
    const body = res.end.mock.calls[0][0];
    expect(body).toContain('worker_jobs_processed_total');
  });
});
