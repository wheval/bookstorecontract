# erc20.cairo
#[starknet::contract]
struct ERC20 {
    total_supply: u256,
    balances: StorageMap<ContractAddress, u256>,
    allowances: StorageMap<(ContractAddress, ContractAddress), u256>,
}

#[starknet::event]
struct TransferEvent {
    from: ContractAddress,
    to: ContractAddress,
    amount: u256,
}

impl ERC20 {
    #[external(v0)]
    fn transfer(
        self: @ERC20, 
        sender: ContractAddress, 
        recipient: ContractAddress, 
        amount: u256
    ) {
        assert self.balances.read(sender) >= amount, "Insufficient balance";
        self.balances.write(sender, self.balances.read(sender) - amount);
        self.balances.write(recipient, self.balances.read(recipient) + amount);
        TransferEvent { from: sender, to: recipient, amount: amount }.emit();
    }

    #[view]
    fn balance_of(self: @ERC20, account: ContractAddress) -> u256 {
        return self.balances.read(account);
    }

    #[view]
    fn total_supply(self: @ERC20) -> u256 {
        return self.total_supply;
    }
}
