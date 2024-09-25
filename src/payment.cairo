# payment.cairo
#[starknet::interface]
struct IPaymentDispatcher {
    fn dispatch_payment(
        self: @IPaymentDispatcher, 
        buyer: ContractAddress, 
        seller: ContractAddress, 
        amount: u256
    );
}

#[starknet::contract]
struct Payment {
    dispatcher: IPaymentDispatcher,
}

impl Payment {
    #[external(v0)]
    fn execute_payment(
        self: @Payment, 
        buyer: ContractAddress, 
        seller: ContractAddress, 
        amount: u256
    ) {
        self.dispatcher.dispatch_payment(buyer, seller, amount);
    }
}
