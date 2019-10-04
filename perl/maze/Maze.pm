#!/usr/bin/perl

package Maze;

use lib '../util';

use warnings;
use strict;
use Carp;

use ClassUtils;
use RandomUtils;
use IllegalArgumentException;

use Cell;
use CellType;


sub new {
    my $type = shift;
    my $this = {
        "cols"=>shift,
        "rows"=>shift
    };
    my $blessed = bless ($this, $type);
    
    my $cells = [];
    my @array_of_cells = ();
    for (my $row=0; $row<$this->rows; ++$row) {
        for (my $col=0; $col<$this->cols; ++$col) {
            my $cell = Cell->new($col,$row,CellType->Out);
            $cells->[$col][$row] = $cell;
            push @array_of_cells, $cell;
        }
    }
    $this->{"cells"} = $cells;
    $this->{"array_of_cells"} = \@array_of_cells;
    
    return $blessed;
}

sub cols {
    return ClassUtils->instance_method_call_check(shift)->{'cols'};
}
sub rows {
    return ClassUtils->instance_method_call_check(shift)->{'rows'};
}


sub get_top_neighbour {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $cell = shift;
    return $this->_check_bounds_and_return_cell($cell->posx, $cell->posy-1);
}
sub get_bottom_neighbour {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $cell = shift;
    return $this->_check_bounds_and_return_cell($cell->posx, $cell->posy+1);
}
sub get_left_neighbour {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $cell = shift;
    return $this->_check_bounds_and_return_cell($cell->posx-1, $cell->posy);
}
sub get_right_neighbour {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $cell = shift;
    return $this->_check_bounds_and_return_cell($cell->posx+1, $cell->posy);
}

sub get_cell_at {
    my $this = ClassUtils->instance_method_call_check(shift);
    my ($posx,$posy) = @_;
    return $this->_check_bounds_and_return_cell($posx, $posy);
}

sub get_neighbours {
    my $this = ClassUtils->instance_method_call_check(shift);
    my ($cell,$type) = @_;
    
    my $neighbour;
    my @result;
    eval {
        $neighbour = $this->get_top_neighbour($cell);
    };
    if (defined $neighbour) {
        push @result, $neighbour  if $this->_cell_is_type_of($neighbour,$type);
    }
    undef $neighbour;
    eval {
        $neighbour = $this->get_bottom_neighbour($cell);
    };
    if (defined $neighbour) {
        push @result, $neighbour  if $this->_cell_is_type_of($neighbour,$type);
    }
    undef $neighbour;
    eval {
        $neighbour = $this->get_left_neighbour($cell);
    };
    if (defined $neighbour) {
        push @result, $neighbour  if $this->_cell_is_type_of($neighbour,$type);
    }
    undef $neighbour;
    eval {
        $neighbour = $this->get_right_neighbour($cell);
    };
    if (defined $neighbour) {
        push @result, $neighbour  if $this->_cell_is_type_of($neighbour,$type);
    }
    
    return @result;
}

sub _cell_is_type_of {
    my $this = ClassUtils->instance_method_call_check(shift);
    my ($cell,$type) = @_;
    
    return !$type || $cell->type == $type;
}

sub cell_type_to_string {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $cell = shift;
    
    return "o" if $cell->type == CellType->Out;
    return "f" if $cell->type == CellType->Frontier;
    return "i" if $cell->type == CellType->In;
    return " ";
}

sub select_random_frontier {
    my $this = ClassUtils->instance_method_call_check(shift);
    
    return $this->_select_random_cell_of_type(CellType->Frontier);
}
sub select_random_out {
    my $this = ClassUtils->instance_method_call_check(shift);
    
    return $this->_select_random_cell_of_type(CellType->Out);
}
sub select_random_in {
    my $this = ClassUtils->instance_method_call_check(shift);
    
    return $this->_select_random_cell_of_type(CellType->In);
}

sub generate_maze {
    my $this = ClassUtils->instance_method_call_check(shift);
    my ($startx,$starty) = @_;
    
    # Start by picking a cell,
    my $initial_cell;
    if (defined $startx && defined $starty) {
        $initial_cell = $this->get_cell_at($startx,$starty);
    }
    else {
        $initial_cell = $this->select_random_out();
    }
    
    # making it "in",
    $initial_cell->mark_as_in();
    $initial_cell->mark_as_start;
    
    # and setting all its neighbors to "frontier".
    foreach my $cell ($this->get_neighbours($initial_cell)) {
        $cell->mark_as_frontier();
    }
    
    # The Maze is done when there are no more "frontier" cells left
    eval {
        # Proceed by picking a "frontier" cell at random
        my $next_frontier = $this->select_random_frontier;
        
        while (1) {
            # carving into it from one of its neighbor cells that are "in"
            $this->_carve_to_random_in_neighbour($next_frontier);
            
            # Change that "frontier" cell to "in"
            $next_frontier->mark_as_in();
            
            # update any of its neighbors that are "out" to "frontier"
            $this->_mark_out_neighbours_to_frontier($next_frontier);
            
            $next_frontier = $this->select_random_frontier;
        }
    };
    if ($@) {
        # The Maze is done when there are no more "frontier" cells left
    }
    
    # open one side of the maze
    my @border_cells = ();
    foreach my $cell (@{$this->_array_of_cells}) {
        push @border_cells, $cell  if ($cell->posx == 0 || $cell->posy == 0 || $cell->posx == $this->cols-1 || $cell->posy == $this->rows-1);
    }
    my $end_cell = RandomUtils->random_item_from_array(@border_cells);
    if ($end_cell->posx == $this->cols-1) { $end_cell->set_right (0); }
    if ($end_cell->posy == $this->rows-1) { $end_cell->set_bottom (0); }
    $end_cell->mark_as_end;
}

sub step {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $message = shift;
    
    print "\n$message\n".$this->to_string;
    my $_input = <>;
}

sub _mark_out_neighbours_to_frontier {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $cell = shift;
    
    eval {
        foreach my $out_cell ($this->get_neighbours($cell,CellType->Out)) {
            $out_cell->mark_as_frontier();
        }
    };
}

sub _carve_to_random_in_neighbour {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $cell = shift;
    
    eval {
        my $cell_in = RandomUtils->random_item_from_array($this->get_neighbours($cell,CellType->In));
        $cell->carve_to($cell_in);
    };
}

sub _select_random_cell_of_type {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $type = shift;
    my @matches;
    
    foreach my $cell (@{$this->_array_of_cells}) {
        push @matches, $cell  if $cell->type == $type;
    }
    
    return RandomUtils->random_item_from_array(@matches);
}


sub _cells {
    return ClassUtils->instance_method_call_check(shift)->{'cells'};
}
sub _array_of_cells {
    return ClassUtils->instance_method_call_check(shift)->{'array_of_cells'};
}

sub _check_bounds_and_return_cell {
    my $this = ClassUtils->instance_method_call_check(shift);
    my ($new_posx, $new_posy) = @_;
    
    if (
        $new_posx < 0 || $new_posx > $this->cols ||
        $new_posy < 0 || $new_posy > $this->rows
    ) {
        croak IllegalArgumentException->new("Position out of bound:($new_posx,$new_posy)");
    }
    
    return $this->_cells->[$new_posx][$new_posy];
}

#+-+
#| |
#+-+
sub to_string {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $result = [];
    my $cells = $this->_cells;
    
    for (my $row=0; $row<$this->rows*2+1; ++$row) {
        for (my $col=0; $col<$this->cols*3+1; ++$col) {
            $result->[$col][$row] = " ";
        }
    }
    for (my $row=0; $row<$this->rows*2+1; ++$row) {
        $result->[0][$row] = "|"  if $row % 2 == 1;
        $result->[0][$row] = "+"  if $row % 2 == 0;
    }
    for (my $col=0; $col<$this->cols*3+1; ++$col) {
        $result->[$col][0] = "-"  if $col % 3 != 0;
        $result->[$col][0] = "+"  if $col % 3 == 0;
    }
    
    for (my $row=0; $row<$this->rows; ++$row) {
        for (my $col=0; $col<$this->cols; ++$col) {
            my $cell = $cells->[$col][$row];
            
            #$result->[1+$col*3][1+$row*2] = $this->cell_type_to_string($cell);
            $result->[1+$col*3][1+$row*2] = "S" if $cell->start;
            $result->[1+$col*3][1+$row*2] = "E" if $cell->end;
            $result->[1+$col*3][1+$row*2+1] = "-" if $cell->get_bottom;
            $result->[1+$col*3+1][1+$row*2+1] = "-" if $cell->get_bottom;
            $result->[1+$col*3+2][1+$row*2] = "|" if $cell->get_right;
            $result->[$col*3+3][1+$row*2+1] = "+";
        }
    }
    
    my $string_result = "";
    for (my $row=0; $row<$this->rows*2+1; ++$row) {
        for (my $col=0; $col<$this->cols*3+1; ++$col) {
            $string_result .= $result->[$col][$row];
        }
        $string_result .= "\n";
    }
    return $string_result;
}

1;
