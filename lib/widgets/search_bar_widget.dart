// lib/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/injection_container.dart';
import '../presentation/hotels/data/models/search_auto_complete_resp_model.dart';
import '../presentation/hotels/presentation/bloc/search_bloc.dart';
import '../presentation/hotels/presentation/bloc/search_event.dart';
import '../presentation/hotels/presentation/bloc/search_state.dart';

class SearchBarWithDropdown extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(SearchResult)? onSelected;

  const SearchBarWithDropdown({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: _SearchContent(
        controller: controller,
        focusNode: focusNode,
        onSelected: onSelected,
      ),
    );
  }
}

class _SearchContent extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(SearchResult)? onSelected;

  const _SearchContent({
    required this.controller,
    required this.focusNode,
    this.onSelected,
  });

  @override
  State<_SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<_SearchContent> {
  OverlayEntry? _overlayEntry;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!widget.focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(List<SearchResult> suggestions) {
    _removeOverlay();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            width: size.width,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(14),
              shadowColor: Colors.black.withOpacity(0.15),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    itemBuilder: (ctx, i) {
                      final item = suggestions[i];
                      return ListTile(
                        leading: _iconFor(item),
                        title: Text(
                          item.valueToDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: _subtitle(item),
                        onTap: () {
                          // STEP 1: Set flag IMMEDIATELY to block onChanged
                          setState(() {
                            _isSelecting = true;
                          });

                          // STEP 2: Update text field
                          widget.controller.text = item.valueToDisplay;
                          widget.controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: widget.controller.text.length),
                          );

                          // STEP 3: Clear suggestions in SearchBloc
                          context.read<SearchBloc>().add(const ClearSuggestions());

                          // STEP 4: Close overlay and unfocus
                          _removeOverlay();
                          widget.focusNode.unfocus();

                          // STEP 5: Notify parent (stores in HomeBloc)
                          widget.onSelected?.call(item);

                          // STEP 6: Reset flag after a delay
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) {
                              setState(() {
                                _isSelecting = false;
                              });
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _iconFor(SearchResult r) {
    final type = r.searchArray.type.toLowerCase();
    if (type.contains('hotel') || type.contains('property')) {
      return const Icon(Icons.hotel, size: 20, color: Color(0xFFFF7B6D));
    }
    if (type.contains('city')) {
      return const Icon(Icons.location_city, size: 20, color: Color(0xFF4CAF50));
    }
    if (type.contains('state')) {
      return const Icon(Icons.map, size: 20, color: Color(0xFF2196F3));
    }
    if (type.contains('country')) {
      return const Icon(Icons.public, size: 20, color: Color(0xFF9C27B0));
    }
    return const Icon(Icons.place, size: 20, color: Colors.grey);
  }

  Widget? _subtitle(SearchResult r) {
    final parts = <String>[];
    if (r.address.city != null) parts.add(r.address.city!);
    if (r.address.state != null) parts.add(r.address.state!);
    if (r.address.country != null) parts.add(r.address.country!);
    if (parts.isEmpty) return null;
    return Text(
      parts.join(', '),
      style: const TextStyle(fontSize: 12, color: Colors.grey),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            final isLoading = state is SearchLoading;
            final hasText = widget.controller.text.isNotEmpty;

            return TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: (value) {
                // CRITICAL FIX: Skip API call if currently selecting from dropdown
                if (_isSelecting) {
                  return; // ← This prevents the API call
                }

                final trimmed = value.trim();

                if (trimmed.isEmpty) {
                  context.read<SearchBloc>().add(const ClearSuggestions());
                  return;
                }

                if (trimmed.length >= 3 && trimmed.length <= 10) {
                  context.read<SearchBloc>().add(SearchTextChanged(trimmed));
                } else {
                  context.read<SearchBloc>().add(const ClearSuggestions());
                }
              },
              decoration: InputDecoration(
                hintText: 'Search hotels, cities, states...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF7B6D)),
                    ),
                  ),
                )
                    : hasText
                    ? IconButton(
                  icon: Icon(Icons.clear,
                      color: Colors.grey.shade600),
                  onPressed: () {
                    widget.controller.clear();
                    setState(() {
                      _isSelecting = false;
                    });
                    context
                        .read<SearchBloc>()
                        .add(const ClearSuggestions());
                    widget.focusNode.unfocus();
                    _removeOverlay();
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
              ),
            );
          },
        ),

        BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            final query = widget.controller.text.trim();
            if (query.isEmpty) return const SizedBox.shrink();

            if (query.length < 3) {
              return Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Type at least 3 characters',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }


            return const SizedBox.shrink();
          },
        ),

        BlocListener<SearchBloc, SearchState>(
          listener: (context, state) {
            if (state is SearchLoaded && state.suggestions.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && widget.focusNode.hasFocus && !_isSelecting) {
                  _showOverlay(state.suggestions);
                }
              });
            } else if (state is SearchError) {
              _removeOverlay();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFFFF7B6D),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is SearchIdle || state is SearchHideOverlay) {
              _removeOverlay();
            }
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}