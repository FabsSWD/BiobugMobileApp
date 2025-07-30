import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/update_product.dart' as update_product_usecase;
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/search_products.dart' as search_products_usecase;
import '../../domain/usecases/get_expiring_products.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

@Injectable()
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final AddProduct _addProduct;
  final update_product_usecase.UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final search_products_usecase.SearchProducts _searchProducts;
  final GetExpiringProducts _getExpiringProducts;
  final InventoryRepository _inventoryRepository;

  ProductBloc(
    this._getProducts,
    this._addProduct,
    this._updateProduct,
    this._deleteProduct,
    this._searchProducts,
    this._getExpiringProducts,
    this._inventoryRepository,
  ) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetail>(_onLoadProductDetail);
    on<SearchProductsEvent>(_onSearchProducts);
    on<FilterProducts>(_onFilterProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<LoadExpiringProducts>(_onLoadExpiringProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    final result = await _getProducts(NoParams());
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products)),
    );
  }

  Future<void> _onLoadProductDetail(LoadProductDetail event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    final result = await _inventoryRepository.getProductById(event.productId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }

  Future<void> _onSearchProducts(SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    final result = await _searchProducts(search_products_usecase.SearchProductsParams(query: event.query));
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products)),
    );
  }

  Future<void> _onFilterProducts(FilterProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    // Implementation would depend on available use cases for filtering
    add(LoadProducts()); // Fallback to load all for now
  }

  Future<void> _onCreateProduct(CreateProduct event, Emitter<ProductState> emit) async {
    final result = await _addProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) {
        emit(ProductCreated(event.product));
        add(LoadProducts()); // Refresh the list
      },
    );
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    final result = await _updateProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) {
        emit(ProductUpdated(event.product));
        add(LoadProducts()); // Refresh the list
      },
    );
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    final result = await _deleteProduct(DeleteProductParams(productId: event.productId));
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) {
        emit(ProductDeleted());
        add(LoadProducts()); // Refresh the list
      },
    );
  }

  Future<void> _onLoadExpiringProducts(LoadExpiringProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    final result = await _getExpiringProducts(GetExpiringProductsParams(daysThreshold: event.daysThreshold));
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products)),
    );
  }
}