# Examples

## Jest (JavaScript / TypeScript)

### Fake (in-memory repository)

```ts
export class FakeOrderRepo {
  private store = new Map<string, Order>();

  add(order: Order): void {
    this.store.set(order.id, order);
  }

  get(orderId: string): Order | undefined {
    return this.store.get(orderId);
  }
}
```

```ts
it("stores and retrieves order state", async () => {
  const repo = new FakeOrderRepo();
  const order = { id: "o-1", totalCents: 2500 };

  repo.add(order);

  expect(repo.get("o-1")).toEqual(order);
});
```

### Stub (scenario-driven gateway)

```ts
const paymentGateway = {
  charge: jest.fn<Promise<string>, [string, number]>(),
};

paymentGateway.charge.mockResolvedValue("pay_o-1");
paymentGateway.charge.mockRejectedValue(new Error("payment failed"));
```

### Spy (outbound effect observation)

```ts
const emailService = {
  sendReceipt: (to: string, orderId: string, paymentId: string) => undefined,
};

const sendReceiptSpy = jest.spyOn(emailService, "sendReceipt");
// ... run use case
expect(sendReceiptSpy).toHaveBeenCalledTimes(1);
expect(sendReceiptSpy).toHaveBeenCalledWith("user@acme.com", "o-1", "pay_o-1");
```

### Mock (contract-focused only)

```ts
const queueClient = {
  publish: jest.fn<Promise<void>, [string, { orderId: string }]>(),
};

queueClient.publish.mockResolvedValue(undefined);
// ...
expect(queueClient.publish).not.toHaveBeenCalled();
```

### JS version (no TypeScript types)

```js
const paymentGateway = { charge: jest.fn() };
paymentGateway.charge.mockResolvedValue("pay_o-1");

const emailService = { sendReceipt: jest.fn() };
// ... run use case
expect(emailService.sendReceipt).toHaveBeenCalledTimes(1);
```
