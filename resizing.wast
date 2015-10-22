(module
    (memory 0)

    (export "power_of_two" $power_of_two)
    (func $power_of_two (result i32)
      (i32.popcnt (page_size))
    )
    
    (export "round_up_to_page" $round_up_to_page)
    (func $round_up_to_page (param i32) (result i32)
      (i32.and (i32.add (get_local 0) (i32.sub (page_size) (i32.const 1)))
                              (i32.sub (i32.const 0) (page_size)))
    )

    (export "load_at_zero" $load_at_zero)
    (func $load_at_zero (result i32) (i32.load (i32.const 0)))

    (export "store_at_zero" $store_at_zero)
    (func $store_at_zero (result i32) (i32.store (i32.const 0) (i32.const 2)))

    (export "load_at_page_size" $load_at_page_size)
    (func $load_at_page_size (result i32) (i32.load (page_size)))

    (export "store_at_page_size" $store_at_page_size)
    (func $store_at_page_size (result i32) (i32.store (page_size) (i32.const 3)))

    (export "grow" $grow)
    (func $grow (param $sz i32)
      (grow_memory (call $round_up_to_page (get_local $sz)))
    )

    (export "size_at_least" $size_at_least)
    (func $size_at_least (param i32) (result i32) (i32.ge_u (memory_size) (get_local 0)))

    (export "size" $size)
    (func $size (result i32) (memory_size))
)

(assert_return (invoke "power_of_two") (i32.const 1))
(assert_return (invoke "size") (i32.const 0))
(assert_return (invoke "size_at_least" (i32.const 0)) (i32.const 1))
(assert_trap (invoke "store_at_zero") "runtime: out of bounds memory access")
(assert_trap (invoke "load_at_zero") "runtime: out of bounds memory access")
(assert_trap (invoke "store_at_page_size") "runtime: out of bounds memory access")
(assert_trap (invoke "load_at_page_size") "runtime: out of bounds memory access")
(invoke "grow" (i32.const 4))
(assert_return (invoke "size_at_least" (i32.const 4)) (i32.const 1))
(assert_return (invoke "load_at_zero") (i32.const 0))
(assert_return (invoke "store_at_zero") (i32.const 2))
(assert_return (invoke "load_at_zero") (i32.const 2))
(assert_trap (invoke "store_at_page_size") "runtime: out of bounds memory access")
(assert_trap (invoke "load_at_page_size") "runtime: out of bounds memory access")
(invoke "grow" (i32.const 4))
(assert_return (invoke "size_at_least" (i32.const 8)) (i32.const 1))
(assert_return (invoke "load_at_zero") (i32.const 2))
(assert_return (invoke "store_at_zero") (i32.const 2))
(assert_return (invoke "load_at_page_size") (i32.const 0))
(assert_return (invoke "store_at_page_size") (i32.const 3))
(assert_return (invoke "load_at_page_size") (i32.const 3))
