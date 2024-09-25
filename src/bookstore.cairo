# bookstore.cairo
from starkware.cairo.common.serialize import serialize
from starkware.cairo.common.math import Math
from starkware.cairo.common.utils import get_hash
from starkware.cairo.common.collections import HashMap
from starkware.starknet.core.storage import StorageMap, StorageMapReadAccess, StorageMapWriteAccess
from starkware.starknet.core.contract_address import ContractAddress

struct Book {
    title: felt252,
    author: felt252,
    price: u128,
    stock: u256,
}

#[starknet::contract]
struct Bookstore {
    bookshelf: StorageMap<u256, Book>, // Maps book ID to Book struct
}

#[starknet::event]
struct PurchaseEvent {
    buyer: ContractAddress,
    book_id: u256,
    amount: u256,
}

impl Bookstore {
    #[external(v0)]
    fn add_book(
        self: @Bookstore, 
        book_id: u256, 
        title: felt252, 
        author: felt252, 
        price: u128, 
        stock: u256
    ) {
        let book = Book { title, author, price, stock };
        self.bookshelf.write(book_id, book);
    }

    #[external(v0)]
    fn purchase_book(
        self: @Bookstore, 
        caller_address: ContractAddress, 
        book_id: u256, 
        amount: u256
    ) {
        let mut book = self.bookshelf.read(book_id);
        assert book.stock >= amount, "Not enough stock";
        book.stock -= amount;
        self.bookshelf.write(book_id, book);
        PurchaseEvent { buyer: caller_address, book_id: book_id, amount: amount }.emit();
    }

    #[view]
    fn get_book_details(self: @Bookstore, book_id: u256) -> Book {
        return self.bookshelf.read(book_id);
    }

    #[view]
    fn get_all_books(self: @Bookstore) -> Array<(u256, felt252, u128)> {
        let mut result: Array<(u256, felt252, u128)> = Array::new();
        for (id, book) in self.bookshelf.iter() {
            result.append((id, book.title, book.price));
        }
        return result;
    }
}
