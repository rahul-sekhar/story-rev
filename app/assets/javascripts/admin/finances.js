$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('finances')) return;
    
    // Table settings for the list of transactions
    var $transactionsTable = $('#transactions-table');
    $transactionsTable.itemTable({
        url: '/admin/transactions',
        selectable: false,
        editable: false,
        removable: false,
        headings: true,
        sortable: true,
        addLinkText: 'New Transaction',
        columns: [
            {
                name: 'Date',
                field: 'formatted_date',
                sort_by: 'timestamp',
                default_sort: 'desc',
                class_name: 'date'
            },
            {
                name: 'Category',
                field: 'transaction_category_name',
                sort_by: 'transaction_category_name',
                type: 'autocomplete',
                sourceURL: '/admin/transaction_categories',
                autocompleteSettings: { searchOnFocus: true }
            },
            {
                name: 'Other Party',
                field: 'other_party',
                sort_by: 'other_party'
            },
            {
                name: 'Payment method',
                field: 'payment_method_name',
                sort_by: 'payment_method_name'
            },
            {
                name: 'Account',
                field: 'account_name',
                sort_by: 'other_party',
            },
            {
                name: 'Notes',
                field: 'notes'
            },
            {
                name: 'Credit',
                field: 'formatted_credit',
                sort_by: 'credit',
                class_name: 'amount'
            },
            {
                name: 'Debit',
                field: 'formatted_debit',
                sort_by: 'debit',
                class_name: 'amount'
            }
        ]
    });
});