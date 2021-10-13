import 'package:flutter/material.dart';

import 'package:flutter_app/model/Image.dart';
import 'package:flutter_app/model/ImagePage.dart';
import 'package:flutter_app/model/fetchImages.dart';

import 'package:flutter_app/model/client.dart';

const catalogLength = 200;

enum RequestType {
  HOME,
  SEARCH,
  USER_SUBMISSIONS
}

class ImageList extends ChangeNotifier {
  /// This is the maximum number of the items we want in memory in each
  /// direction from the current position. For example, if the user
  /// is currently looking at item number 400, we don't want item number
  /// 0 to be kept in memory.
  static const maxCacheDistance = 100;

  /// The internal store of pages that we got from [fetchPage].
  /// The key of the map is the starting index of the page, for faster
  /// access.
  final Map<int, ItemPage> _pages = {};

  void clear() {
    _pages.clear();
  }

  /// A set of pages (represented by their starting index) that have started
  /// the fetch process but haven't ended it yet.
  ///
  /// This is to prevent fetching of a page several times in a row. When a page
  /// is already being fetched, we don't initiate another fetch request.
  final Set<int> _pagesBeingFetched = {};

  /// The size of the catalog. This is `null` at first, and only when the user
  /// reaches the end of the catalog, it will hold the actual number.
  int itemCount;

  /// After the catalog is disposed, we don't allow it to call
  /// [notifyListeners].
  bool _isDisposed = false;

  RequestType _requestType = RequestType.HOME;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// This is a synchronous method that returns the item at [index].
  ///
  /// If the item is already in memory, this will just return it. Otherwise,
  /// this method will initiate a fetch of the corresponding page, and will
  /// return [Item.loading].
  ///
  /// The UI will be notified via [notifyListeners] when the fetch
  /// is completed. At that time, calling this method will return the newly
  /// fetched item.
  Item getByIndex(Client client, int index, String query, String searchParams) {
    // Compute the starting index of the page where this item is located.
    // For example, if [index] is `42` and [itemsPerPage] is `20`,
    // then `index ~/ itemsPerPage` (integer division)
    // evaluates to `2`, and `2 * 20` is `40`.
    var startingIndex = (index ~/ itemsPerPage) * itemsPerPage;

    try {
      // If the corresponding page is already in memory, return immediately.
      if (_pages.containsKey(startingIndex)) {
        var item = _pages[startingIndex].items[index - startingIndex];
        return item;
      }

    // We don't have the data yet. Start fetching it.
    _fetchPage(client, startingIndex, query, searchParams);

      // In the meantime, return a placeholder.
      return Item.loading();
    } catch (ex) {
      return Item.loading();
    }
  }

  Item getHomeByIndex(Client client, String moreParameters, int index) {
    // Compute the starting index of the page where this item is located.
    // For example, if [index] is `42` and [itemsPerPage] is `20`,
    // then `index ~/ itemsPerPage` (integer division)
    // evaluates to `2`, and `2 * 20` is `40`.
    var startingIndex = (index ~/ itemsPerPage) * itemsPerPage;

    try {
      // If the corresponding page is already in memory, return immediately.
      if (_pages.containsKey(startingIndex)) {
        var item = _pages[startingIndex].items[index - startingIndex];
        return item;
      }

      // We don't have the data yet. Start fetching it.
      _fetchHomePage(client, moreParameters, startingIndex);

      // In the meantime, return a placeholder.
      return Item.loading();
    } catch (ex) {
      return Item.loading();
    }
  }

  Item getSearchByIndex(Client client, String search, String searchParams, int index) {
    // Compute the starting index of the page where this item is located.
    // For example, if [index] is `42` and [itemsPerPage] is `20`,
    // then `index ~/ itemsPerPage` (integer division)
    // evaluates to `2`, and `2 * 20` is `40`.
    var startingIndex = (index ~/ itemsPerPage) * itemsPerPage;

    try {
      // If the corresponding page is already in memory, return immediately.
      if (_pages.containsKey(startingIndex)) {
        var item = _pages[startingIndex].items[index - startingIndex];
        return item;
      }

    // We don't have the data yet. Start fetching it.
    _fetchSearchPage(client, search, searchParams, startingIndex);

      // In the meantime, return a placeholder.
      return Item.loading();
    } catch (ex) {
      return Item.loading();
    }
  }

  Future<void> _fetchSearchPage(Client client, String search, String searchParams, int startingIndex) async {
    if (_pagesBeingFetched.contains(startingIndex)) {
      // Page is already being fetched. Ignore the redundant call.
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final page = await fetchPage(client, search, searchParams);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      // The returned page has no next page. This means we now know the size
      // of the catalog.
      itemCount = startingIndex + page.items.length;
    }

    // Store the new page.
    _pages[startingIndex] = page;
    _pruneCache(startingIndex);

    if (!_isDisposed) {
      // Notify the widgets that are listening to the catalog that they
      // should rebuild.
      notifyListeners();
    }
  }

  Item getFavoriteByIndex(Client client, int index) {
    // Compute the starting index of the page where this item is located.
    // For example, if [index] is `42` and [itemsPerPage] is `20`,
    // then `index ~/ itemsPerPage` (integer division)
    // evaluates to `2`, and `2 * 20` is `40`.
    try
    {
      var startingIndex = (index ~/ itemsPerPage) * itemsPerPage;

      // If the corresponding page is already in memory, return immediately.
      if (_pages.containsKey(startingIndex)) {
        var item = _pages[startingIndex].items[index - startingIndex];
        return item;
      }

      // We don't have the data yet. Start fetching it.
      _fetchFavoritePage(client, startingIndex);

      // In the meantime, return a placeholder.
      return Item.loading();
    } catch (ex) {
      return Item.loading();
    }
  }

  Future<void> _fetchFavoritePage(Client client, int startingIndex) async {
    if (_pagesBeingFetched.contains(startingIndex)) {
      // Page is already being fetched. Ignore the redundant call.
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final page = await getFavoriteImages(client);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      // The returned page has no next page. This means we now know the size
      // of the catalog.
      itemCount = startingIndex + page.items.length;
    }

    // Store the new page.
    _pages[startingIndex] = page;
    _pruneCache(startingIndex);

    if (!_isDisposed) {
      // Notify the widgets that are listening to the catalog that they
      // should rebuild.
      notifyListeners();
    }
  }

  Item getProfileImageByIndex(Client client, int index) {
    // Compute the starting index of the page where this item is located.
    // For example, if [index] is `42` and [itemsPerPage] is `20`,
    // then `index ~/ itemsPerPage` (integer division)
    // evaluates to `2`, and `2 * 20` is `40`.
    var startingIndex = (index ~/ itemsPerPage) * itemsPerPage;

    try {
      // If the corresponding page is already in memory, return immediately.
      if (_pages.containsKey(startingIndex)) {
        var item = _pages[startingIndex].items[index - startingIndex];
        return item;
      }

      // We don't have the data yet. Start fetching it.
      _fetchProfileImagePage(client, startingIndex);

      // In the meantime, return a placeholder.
      return Item.loading();
    } catch (ex) {
      return Item.loading();
    }
  }

  Future<void> _fetchProfileImagePage(Client client, int startingIndex) async {
    print(startingIndex);
    if (_pagesBeingFetched.contains(startingIndex)) {
      // Page is already being fetched. Ignore the redundant call.
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final page = await getProfileImages(client);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      // The returned page has no next page. This means we now know the size
      // of the catalog.
      itemCount = startingIndex + page.items.length;
    }

    // Store the new page.
    _pages[startingIndex] = page;
    _pruneCache(startingIndex);

    if (!_isDisposed) {
      // Notify the widgets that are listening to the catalog that they
      // should rebuild.
      notifyListeners();
    }
  }

  Item sortHomeByIndex(Client client, int index) {
    // Compute the starting index of the page where this item is located.
    // For example, if [index] is `42` and [itemsPerPage] is `20`,
    // then `index ~/ itemsPerPage` (integer division)
    // evaluates to `2`, and `2 * 20` is `40`.
    var startingIndex = (index ~/ itemsPerPage) * itemsPerPage;

    try {
      // If the corresponding page is already in memory, return immediately.
      if (_pages.containsKey(startingIndex)) {
        var item = _pages[startingIndex].items[index - startingIndex];
        return item;
      }

      // We don't have the data yet. Start fetching it.
      _fetchSortHomePage(client, startingIndex);

      // In the meantime, return a placeholder.
      return Item.loading();
    } catch (ex) {
      return Item.loading();
    }
  }

  Future<void> _fetchSortHomePage(Client client, int startingIndex) async {
    print(startingIndex);
    if (_pagesBeingFetched.contains(startingIndex)) {
      // Page is already being fetched. Ignore the redundant call.
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final page = await getProfileImages(client);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      // The returned page has no next page. This means we now know the size
      // of the catalog.
      itemCount = startingIndex + page.items.length;
    }

    // Store the new page.
    _pages[startingIndex] = page;
    _pruneCache(startingIndex);

    if (!_isDisposed) {
      // Notify the widgets that are listening to the catalog that they
      // should rebuild.
      notifyListeners();
    }
  }

  Future<void> _fetchHomePage(Client client, String moreParameters, int startingIndex) async {
    if (_pagesBeingFetched.contains(startingIndex)) {
      // Page is already being fetched. Ignore the redundant call.
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final page = await getHomePage(client, moreParameters);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      // The returned page has no next page. This means we now know the size
      // of the catalog.
      itemCount = startingIndex + page.items.length;
    }

    // Store the new page.
    _pages[startingIndex] = page;
    _pruneCache(startingIndex);

    if (!_isDisposed) {
      // Notify the widgets that are listening to the catalog that they
      // should rebuild.
      notifyListeners();
    }
  }

  /// This method initiates fetching of the [ItemPage] at [startingIndex].
  Future<void> _fetchPage(Client client,int startingIndex, String query, String searchParams) async {
    if (_pagesBeingFetched.contains(startingIndex)) {
      // Page is already being fetched. Ignore the redundant call.
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final username = client.username;
    final page = await fetchPage(client, query, searchParams);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      // The returned page has no next page. This means we now know the size
      // of the catalog.
      itemCount = startingIndex + page.items.length;
    }

    // Store the new page.
    _pages[startingIndex] = page;
    _pruneCache(startingIndex);

    if (!_isDisposed) {
      // Notify the widgets that are listening to the catalog that they
      // should rebuild.
      notifyListeners();
    }
  }

  /// Removes item pages that are too far away from [currentStartingIndex].
  void _pruneCache(int currentStartingIndex) {
    // It's bad practice to modify collections while iterating over them.
    // So instead, we'll store the keys to remove in a separate Set.
    final keysToRemove = <int>{};
    for (final key in _pages.keys) {
      if ((key - currentStartingIndex).abs() > maxCacheDistance) {
        // This page's starting index is too far away from the current one.
        // We'll remove it.
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _pages.remove(key);
    }
  }
}